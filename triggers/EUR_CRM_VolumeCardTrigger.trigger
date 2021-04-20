trigger EUR_CRM_VolumeCardTrigger on EUR_CRM_ID_Card__c (after update) {

    //Set<Id> accountIdSet = new Set<Id>();
    //Map of Account Id and ID Card
    Map<Id, EUR_CRM_ID_Card__c> volCardMap = new Map<Id, EUR_CRM_ID_Card__c>();
    
    Map<Id, EUR_CRM_ID_Card__c> volCardSuperPremiumdMap = new Map<Id, EUR_CRM_ID_Card__c>();
    for (EUR_CRM_ID_Card__c idCard : Trigger.new)
    {
        if (idCard.EUR_CRM_Total_Annual_Volume__c != Trigger.oldMap.get(idCard.Id).EUR_CRM_Total_Annual_Volume__c)
        {
            volCardMap.put(idCard.EUR_CRM_Outlet__c, idCard);
        }
        
        if(idCard.EUR_CRM_Total_Super_Ultra_Brands__c != Trigger.oldMap.get(idCard.Id).EUR_CRM_Total_Super_Ultra_Brands__c)
        {
            volCardSuperPremiumdMap.put(idCard.EUR_CRM_Outlet__c, idCard);
        }
    }
    
    System.debug('Flag - ID Card Trigger - For Volume Potential:' + volCardMap);
    System.debug('Flag - ID Card Trigger - For Image Level:' + volCardSuperPremiumdMap);
    
    if (volCardMap.size()>0)
    {
        //Get Pros Segmentation
        List<EUR_CRM_Pros_Segmentation__c> prosSegmentations = [SELECT Id, RecordTypeId,
                                                EUR_CRM_Standard_Account__c,
                                                EUR_CRM_Account__c,
                                                EUR_CRM_Affiliate__c, 
                                                EUR_CRM_country_code__c ,
                                                EUR_CRM_Affiliate__r.EUR_CRM_Decision_Tree__c,
                                                EUR_CRM_Affiliate__r.Name,
                                                EUR_CRM_Group_Outlet_Type__c, 
                                                EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Image_Criteria_Set__c,
                                                EUR_CRM_Image_Level__c, 
                                                EUR_CRM_Outlet_Type__c, EUR_CRM_Volume_Potential__c,
                                                EUR_CRM_Service_Pack__c
                                                FROM EUR_CRM_Pros_Segmentation__c 
                                                WHERE EUR_CRM_Standard_Account__c IN:volCardMap.keySet()];
        //Assign Volume Potential
        System.debug('Flag - ID Card Trigger - For Volume Potential 2:' + volCardMap + '-' + prosSegmentations);
        if(prosSegmentations.size()>0)
        {
            EUR_CRM_ProsSegmentationClass.assignVolumePotential(prosSegmentations, volCardMap);
        }
    }
    
    if(volCardSuperPremiumdMap.size()>0)
    {
        Map<Id, EUR_CRM_Pros_Segmentation__c> prosSegmentationMap = new Map<Id, EUR_CRM_Pros_Segmentation__c>([
                                                SELECT Id, RecordTypeId,
                                                EUR_CRM_Standard_Account__c,
                                                EUR_CRM_Account__c,
                                                EUR_CRM_Affiliate__c, 
                                                EUR_CRM_country_code__c ,
                                                EUR_CRM_Affiliate__r.EUR_CRM_Decision_Tree__c,
                                                EUR_CRM_Affiliate__r.Name,
                                                EUR_CRM_Group_Outlet_Type__c,
                                                EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Image_Criteria_Set__c,
                                                EUR_CRM_Image_Level__c, 
                                                EUR_CRM_Outlet_Type__c, EUR_CRM_Volume_Potential__c,
                                                EUR_CRM_Service_Pack__c, EUR_CRM_Total_Image_Level_Weight__c
                                                FROM EUR_CRM_Pros_Segmentation__c 
                                                WHERE EUR_CRM_Standard_Account__c IN:volCardSuperPremiumdMap.keySet()]);
        if (prosSegmentationMap.size()>0)
        {
            System.debug('Flag - Volume Card SuperPremium Trigger: '+ prosSegmentationMap +'|'+volCardSuperPremiumdMap);
            EUR_CRM_ProsSegmentationClass.assignImageLevel(prosSegmentationMap, volCardSuperPremiumdMap);
        }
    }
}