/*
*    Description : Test class for EUR_CRM_ImageLevelThresholdMassUpdate
*
*    Version    Author        Date        Description
*    1.0        Sid           01/22/2105  Initial Draft
*/

@isTest
public class EUR_CRM_ImageLevelThresholdMasUpdateTest {

    private static List<EUR_CRM_Pros_Segmentation__c> prosSegmentationList = new List<EUR_CRM_Pros_Segmentation__c>();
    private static List<EUR_CRM_Image_Level__c> imageLevelList = new List<EUR_CRM_Image_Level__c>();
    private static List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypeList = new List<EUR_CRM_Group_Outlet_Type__c>();
    private static List<EUR_CRM_Image_Level_Threshold__c> imageLevelThresholdList = new List<EUR_CRM_Image_Level_Threshold__c>();

    //Method to create test data
    public static void insertTestData(){
    
        //Create Group Outlet Type
        groupOutletTypeList = EUR_CRM_TestClassUtilityHelper.createGroupOutletType(1, 'EUR DE Group Outlet', '', null, null);
        for(EUR_CRM_Group_Outlet_Type__c objGroupOutletType : groupOutletTypeList){
            objGroupOutletType.EUR_CRM_Group_Outlet_Name__c = 'NightClub';
        }
        insert groupOutletTypeList;
        
        //Create Image Level Record
        imageLevelList = EUR_CRM_TestClassUtilityHelper.createImageLevel(1, 'DE Image Level', '', null, 'Nightclub');
        insert imageLevelList;        
        
        //Create Image Level Threshold
        imageLevelThresholdList = EUR_CRM_TestClassUtilityHelper.createImageLevelThreshold(1, groupOutletTypeList[0].Id, imageLevelList[0].Id);
        for(EUR_CRM_Image_Level_Threshold__c objImgLvlThrshold : imageLevelThresholdList){
            
            objImgLvlThrshold.EUR_CRM_Min_Weight__c = 50;
            objImgLvlThrshold.EUR_CRM_Is_Weight_Changed__c = true;
        }
        insert imageLevelThresholdList;
        
        //Create PROS Segmentation
        prosSegmentationList = EUR_CRM_TestClassUtilityHelper.createProsSegmentation(1, 'EUR_DE_PROS_Segmentation', 
                                                                                     '', null, 
                                                                                     groupOutletTypeList[0].Id, null, 
                                                                                     null, null, null);
                                                                                     
        for(EUR_CRM_Pros_Segmentation__c objProsSeg : prosSegmentationList){
            
            objProsSeg.EUR_CRM_Image_Level_Threshold__c = imageLevelThresholdList[0].Id;
            objProsSeg.EUR_CRM_Image_Level__c = imageLevelList[0].Id;
        }                                                                                     
        insert prosSegmentationList;        
    }

    //Test Method to test Batch
    static testMethod void executeBatchTest() {
        
        insertTestData();
        test.startTest();
            EUR_CRM_ImageLevelThresholdMassUpdate oEUR_CRM_ImageLevelThresholdMassUpdate = new EUR_CRM_ImageLevelThresholdMassUpdate('DE');
            database.executeBatch(oEUR_CRM_ImageLevelThresholdMassUpdate);
        test.stopTest();
    }
}