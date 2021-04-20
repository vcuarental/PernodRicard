trigger ASI_CRM_SG_VolumeCardTrigger on ASI_CRM_ID_Card__c (after update) {

    //Set<Id> accountIdSet = new Set<Id>();
    //Map of Account Id and ID Card
    Map<Id, ASI_CRM_ID_Card__c> volCardMap = new Map<Id, ASI_CRM_ID_Card__c>();
    
    Map<Id, ASI_CRM_ID_Card__c> volCardSuperPremiumdMap = new Map<Id, ASI_CRM_ID_Card__c>();
    for (ASI_CRM_ID_Card__c idCard : Trigger.new)
    {
        if (idCard.ASI_CRM_SG_Total_Annual_Volume__c != Trigger.oldMap.get(idCard.Id).ASI_CRM_SG_Total_Annual_Volume__c)
        {
            volCardMap.put(idCard.ASI_CRM_SG_Outlet__c, idCard);
        }
        
        if(idCard.ASI_CRM_SG_Total_Super_Ultra_Brands__c != Trigger.oldMap.get(idCard.Id).ASI_CRM_SG_Total_Super_Ultra_Brands__c)
        {
            volCardSuperPremiumdMap.put(idCard.ASI_CRM_SG_Outlet__c, idCard);
        }
    }
    
    System.debug('Flag - ID Card Trigger - For Volume Potential:' + volCardMap);
    System.debug('Flag - ID Card Trigger - For Image Level:' + volCardSuperPremiumdMap);
    
    if (volCardMap.size()>0)
    {
        //Get Pros Segmentation
        List<ASI_CRM_Pros_Segmentation__c> prosSegmentations = [SELECT Id, RecordTypeId,
                                                ASI_CRM_SG_Customer__c,
                                                ASI_CRM_SG_Account__c,
                                                ASI_CRM_SG_Group_Outlet_Type__c, 
                                                ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Image_Criteria_Set__c,
                                                ASI_CRM_SG_Image_Level__c, 
                                                ASI_CRM_SG_Outlet_Type__c, ASI_CRM_SG_Volume_Potential__c,
                                                ASI_CRM_SG_Service_Pack__c
                                                FROM ASI_CRM_Pros_Segmentation__c 
                                                WHERE ASI_CRM_SG_Customer__c IN:volCardMap.keySet()];
        //Assign Volume Potential
        System.debug('Flag - ID Card Trigger - For Volume Potential 2:' + volCardMap + '-' + prosSegmentations);
        if(prosSegmentations.size()>0)
        {
            ASI_CRM_ProsSegmentationClass.assignVolumePotential(prosSegmentations, volCardMap);
        }
    }
    
    if(volCardSuperPremiumdMap.size()>0)
    {
        Map<Id, ASI_CRM_Pros_Segmentation__c> prosSegmentationMap = new Map<Id, ASI_CRM_Pros_Segmentation__c>([
                                                SELECT Id, RecordTypeId,
                                                ASI_CRM_SG_Customer__c,
                                                ASI_CRM_SG_Account__c,
                                                ASI_CRM_SG_Group_Outlet_Type__c,
                                                ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Image_Criteria_Set__c,
                                                ASI_CRM_SG_Image_Level__c, 
                                                ASI_CRM_SG_Outlet_Type__c, ASI_CRM_SG_Volume_Potential__c,
                                                ASI_CRM_SG_Service_Pack__c, ASI_CRM_SG_Total_Image_Level_Weight__c
                                                FROM ASI_CRM_Pros_Segmentation__c 
                                                WHERE ASI_CRM_SG_Customer__c IN:volCardSuperPremiumdMap.keySet()]);
        if (prosSegmentationMap.size()>0)
        {
            System.debug('Flag - Volume Card SuperPremium Trigger: '+ prosSegmentationMap +'|'+volCardSuperPremiumdMap);
            ASI_CRM_ProsSegmentationClass.assignImageLevel(prosSegmentationMap, volCardSuperPremiumdMap);
        }
    }
}