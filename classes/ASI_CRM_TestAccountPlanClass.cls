@isTest 
public with sharing class ASI_CRM_TestAccountPlanClass{
    private static ASI_CRM_AccountsAdditionalField__c account; 
    private static ASI_CRM_Pros_Segmentation__c prosSegmentation;
    private static ASI_CRM_Group_Outlet_Type__c grpOutletType;
    private static ASI_CRM_Outlet_Type__c outletType;
    private static ASI_CRM_Image_Level__c imageLevel;
    private static ASI_CRM_Image_Level_Threshold__c imageLevelThreshold;
    private static ASI_CRM_Volume_Potential__c mediumVolPotential;
    private static ASI_CRM_Volume_Potential_Threshold__c mediumVolPotentialThreshold;
    private static ASI_CRM_DAMD_Threshold__c damdhigh;
    private static ASI_CRM_ServicePack__c servicePack;
    private static User user1;
    
    public static void dataInsert(){
        
            grpOutletType = ASI_CRM_TestClassUtilityHelperPROS.createGroupOutletType(1, 'ASI_CRM_SG_Group_Outlet_Type', '', null, null)[0];
            grpOutletType.ASI_CRM_SG_Name__c = 'Restaurant';
            grpOutletType.ASI_CRM_SG_Group_Outlet_Name__c = 'Restaurant';
            insert grpOutletType;
            
            outletType = ASI_CRM_TestClassUtilityHelperPROS.createOutletType(1, 'ASI_CRM_SG_Outlet_Type', '', grpOutletType.Id)[0];
            outletType.ASI_CRM_SG_Name__c = 'Western Restaurant';
            insert outletType;
            
            imageLevel = ASI_CRM_TestClassUtilityHelperPROS.createImageLevel(1, 'ASI_CRM_SG_Image_Level', '', grpOutletType.Id, 'Iconic')[0];
            imageLevel.ASI_CRM_SG_External_ID__c = 'TEST001';
            insert imageLevel;
            
            
            imageLevelThreshold = ASI_CRM_TestClassUtilityHelperPROS.createImageLevelThreshold(1, grpOutletType.Id, imageLevel.Id)[0];
            insert imageLevelThreshold;
            
            mediumVolPotential = (ASI_CRM_TestClassUtilityHelperPROS.createvolumePotential(1,'ASI_CRM_SG_Volume_Potential','SGD',grpOutletType.id,'Medium')).get(0);
            insert mediumVolPotential;        
            mediumVolPotentialThreshold = (ASI_CRM_TestClassUtilityHelperPROS.createvolumePotentialThreshold(1,grpOutletType.id,mediumVolPotential.id,1000)).get(0);
            insert mediumVolPotentialThreshold;
            damdhigh = ASI_CRM_TestClassUtilityHelperPROS.createDAMD(1, 'ASI_CRM_SG_DAMD_Threshold', grpOutletType.Id, mediumVolPotential.Id, 'Attack', 'High', 0.01)[0];
            insert damdhigh;
            
           // prosSegmentation  = [select id, RecordTypeId , ASI_CRM_Group_Outlet_Type__c ,ASI_CRM_Image_Level__c , ASI_CRM_Outlet_Type__c ,ASI_CRM_Volume_Potential__c , ASI_CRM_Image_Level_Threshold__c  from ASI_CRM_Pros_Segmentation__c where ASI_Crm_account__c =: account.Id];
           account = ASI_CRM_TestClassUtilityHelperPROS.createAccountsASI(1, 'ASI_CRM_SG_Outlet')[0];
           account.ASI_CRM_SG_Image_Level__c = imageLevel.Id;
           insert account;
            
           prosSegmentation = ASI_CRM_TestClassUtilityHelperPROS.createProsSegmentation(1, 'ASI_CRM_SG_PROS_Segmentation', '', account.Id, grpOutletType.Id, outletType.Id, imageLevel.Id, mediumVolPotential.Id)[0];
           prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c = imageLevelThreshold.Id;
           prosSegmentation.ASI_CRM_SG_DAMD_Threshold__c = damdhigh.Id;
           insert prosSegmentation; 
    }
    
    static testMethod void testAccountPlan1(){
       dataInsert();
       
       servicePack = ASI_CRM_TestClassUtilityHelperPROS.createServicePack(1, 'ASI_CRM_SG_ServicePack', 'Restaurant', 'Iconic')[0];
       servicePack.ASI_CRM_SG_Outlet_Type__c = 'Restaurant';
       servicePack.ASI_CRM_SG_DAMD_Action__c = 'Attack';
       servicePack.ASI_CRM_SG_Sub_Outlet_Type__c = 'Western Restaurant';
       servicePack.ASI_CRM_SG_Segmentation__c = 'Iconic';
       system.debug('**'+servicePack.RecordTypeId);
       insert servicePack;
       
       ASI_CRM_ServicePackItem__c servicePackItem = new ASI_CRM_ServicePackItem__c();
       servicePackItem.ASI_CRM_ServicePack__c = servicePack.Id;
       servicePackItem.ASI_CRM_SG_Act_Vis__c = 'Activation';
       insert servicePackItem;
       
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(prosSegmentation);
        PageReference rf = new Pagereference('/apex/ASI_CRM_ProsSegmentationPage');
        rf.getParameters().put('id', prosSegmentation.id);
        Test.setCurrentPage(rf);
        
        ASI_CRM_AccountPlanClass accountPlanController = new ASI_CRM_AccountPlanClass(standardController);
        accountPlanController.gotoProsSegmentation();
        accountPlanController.getSerPack();

    }
}