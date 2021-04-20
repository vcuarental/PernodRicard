@IsTest
private class EUR_CRM_PRSegmentationClassTest {

    @IsTest
    static void testMethod1(){
        EUR_CRM_PRS_TestClassUtilityHelper.testInitBE_OnTradeGut();
        Test.startTest();
        EUR_CRM_PRS_Segmentation__c prsSeg = [SELECT Id, EUR_CRM_Account__c FROM EUR_CRM_PRS_Segmentation__c LIMIT 1];
        EUR_CRM_Account__c acc = [SELECT Id, EUR_CRM_Brand_Building_Potential__r.EUR_CRM_Segmentation_BBP_Aspect_Name__c,
            EUR_CRM_Brand_Building_Potential__c, EUR_CRM_Business_Potential__r.EUR_CRM_Segmentation_BP_Aspect_Name__c,
            EUR_CRM_Business_Potential__c, EUR_CRM_PRS_Image_Level__r.EUR_CRM_Segmentation_IL_Aspect_Name__c,
            EUR_CRM_PRS_Volume_Potential__r.EUR_CRM_Segmentation_VP_Aspect_Name__c
        FROM EUR_CRM_Account__c WHERE Id=:prsSeg.EUR_CRM_Account__c LIMIT 1];
        EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType = [SELECT Id FROM EUR_CRM_PRS_Group_Outlet_Type__c LIMIT 1];

        EUR_CRM_PRS_Segmentation__c retPrsSeg = EUR_CRM_PRSegmentationClass.returnPRSegmentationViaId(prsSeg.Id);
        System.assertEquals(retPrsSeg.Id, prsSeg.Id);
        EUR_CRM_PRS_Group_Outlet_Type__c retgroupOutletType = EUR_CRM_PRSegmentationClass.returnPRSGroupOutletTypeViaId(groupOutletType.Id);
        System.assertEquals(retgroupOutletType.Id, groupOutletType.Id);

        System.assert(!EUR_CRM_PRSegmentationClass.returnImageLevelLabels().isEmpty());
        System.assert(!EUR_CRM_PRSegmentationClass.returnVolumePotentialLabels().isEmpty());
        EUR_CRM_PRSegmentationClass.returnBrandBuildingPotentialByCountry(new Set<String>{'BE'});
        EUR_CRM_PRSegmentationClass.returnBusinessPotentialsByCountry(new Set<String>{'BE'});
        EUR_CRM_PRSegmentationClass.returnImageLevelsByCountry(new Set<String>{'BE'});
        EUR_CRM_PRSegmentationClass.returnVolumePotentialsByCountry(new Set<String>{'BE'});
        EUR_CRM_PRSegmentationClass.returnGroupOutletTypeByCountry(new Set<String>{'BE'});
        EUR_CRM_PRSegmentationClass.returnOutletTypeByCountry(new Set<String>{'BE'});

        EUR_CRM_PRSegmentationClass.returnBusinessPotentialFinalResultsCriteria(groupOutletType.Id, 'BE');
        EUR_CRM_PRSegmentationClass.returnImageLevelFinalResultsCriteria(groupOutletType.Id, 'BE');
        EUR_CRM_PRSegmentationClass.returnVolumePotentialFinalResultsCriteria(groupOutletType.Id, 'BE');
        EUR_CRM_PRSegmentationClass.returnBrandBuildingPotentialFinalResultsCriteria(groupOutletType.Id, 'BE');
//        EUR_CRM_PRSegmentationClass.returnPROFSPotentialMatrix(retPrsSeg);
//        EUR_CRM_PRSegmentationClass.returnEUAccountPROFSPotentialMatrix(acc);
//        EUR_CRM_PRSegmentationClass.returnPROSPotentialMatrix(retPrsSeg);
//        EUR_CRM_PRSegmentationClass.returnEUAccountPROSPotentialMatrix(acc);
        EUR_CRM_PRSegmentationClass.returnPRSQuestionsAndPossibleAnswersList(null);
        EUR_CRM_PRSegmentationClass.returnPriorityLevelMatrices('BE');

        Test.stopTest();
    }
}