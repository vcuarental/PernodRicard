/*
  @Company:     IP-Converge Data Services, Inc.
  @Description: Test Class for EUR_CRM_AccountPlanClass Class.
  @Author:      IPC
  @History:     APR.19.2014 - Created
                APR.23.2014 - modified methods and test data creation.
*/
@isTest 
public with sharing class EUR_CRM_TestAccountPlanClass{
    private static EUR_CRM_Account__c account; 
    private static EUR_CRM_Pros_Segmentation__c prosSegmentation;
    private static EUR_CRM_Group_Outlet_Type__c grpOutletType;
    private static EUR_CRM_Image_Level__c imageLevel;
    private static EUR_CRM_Image_Level_Threshold__c imageLevelThreshold;
    private static EUR_CRM_Service_Pack__c servicePack;
    private static EUR_CRM_Affiliate__c affiliate;
    private static User user;
    
    public static void dataInsert(){ 
            
        
            grpOutletType = EUR_CRM_TestClassUtilityHelper.createGroupOutletType(1, 'EUR LT Group Outlet', '', null, null)[0];
            grpOutletType.EUR_CRM_Name__c = 'Restaurant';
            grpOutletType.EUR_CRM_Group_Outlet_Name__c = 'Restaurant';
            insert grpOutletType;
            
            imageLevel = EUR_CRM_TestClassUtilityHelper.createImageLevel(1, 'LT Image Level', '', grpOutletType.Id, 'Iconic')[0];
            imageLevel.EUR_CRM_External_ID__c = 'TEST001';
            insert imageLevel;
            
            account = EUR_CRM_TestClassUtilityHelper.createAccountsEU(1, 'LT Direct - On Trade')[0];
            account.EUR_CRM_Postal_Code__c = '12345';
            account.EUR_CRM_3_Most_Pop_Prod_Categories__c = 'Vodka;Rum;Beer';
            account.EUR_CRM_Image_Level__c = imageLevel.Id;
            insert account;    
        
            imageLevelThreshold = EUR_CRM_TestClassUtilityHelper.createImageLevelThreshold(1, grpOutletType.Id, imageLevel.Id)[0];
            insert imageLevelThreshold;
            
           // prosSegmentation  = [select id, RecordTypeId , EUR_CRM_Group_Outlet_Type__c ,EUR_CRM_Image_Level__c , EUR_CRM_Outlet_Type__c ,EUR_CRM_Volume_Potential__c , EUR_CRM_Image_Level_Threshold__c  from EUR_CRM_Pros_Segmentation__c where eur_Crm_account__c =: account.Id];
            
           prosSegmentation = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_LT_PROS_Segmentation', '', account.Id, grpOutletType.Id, null, imageLevel.Id, null, null)[0];
           prosSegmentation.EUR_CRM_Image_Level_Threshold__c = imageLevelThreshold.Id;
           insert prosSegmentation; 
    }
    
    static testMethod void testAccountPlan1(){
       dataInsert();
       servicePack = EUR_CRM_TestClassUtilityHelper.createServicePack(1, 'EUR LT Service Pack', 'Restaurant', 'Iconic')[0];
       servicePack.EUR_CRM_Outlet_Type__c = 'Restaurant';
       insert servicePack;
       
       //Added By Laputa Hugo Cheung 28/09/2016
       servicePack = [SELECT Id, RecordTypeId, EUR_CRM_Country_Code__c, EUR_CRM_Outlet_Type__c, EUR_CRM_Segmentation__c FROM EUR_CRM_Service_Pack__c WHERE Id = :servicePack.Id LIMIT 1];
       
       EUR_CRM_Service_Pack_Item__c servicePackItem = new EUR_CRM_Service_Pack_Item__c();
       servicePackItem.EUR_CRM_Service_Pack__c = servicePack.Id;
       servicePackItem.EUR_CRM_Presence__c = true;
       insert servicePackItem;
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/EUR_CRM_ProsSegmentationPage');
        rf.getParameters().put('id', prosSegmentation.id);
        Test.setCurrentPage(rf);
        
        EUR_CRM_AccountPlanClass accountPlanController = new EUR_CRM_AccountPlanClass(standardController);
        accountPlanController.gotoProsSegmentation(); 
         
    }
}