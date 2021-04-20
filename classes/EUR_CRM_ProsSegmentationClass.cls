public with sharing class EUR_CRM_ProsSegmentationClass {
    
    private static final String VOLUME_POTENTIAL_STATEMENT = 'Potential Volume';
    public static final String IMAGE_LEVEL_STATEMENT = 'Numero de marcas Super e Ultra Premium?';
    public static final String ANSWER_WEIGHT = 'AnswerWeight';
    public static final String TOTAL_WEIGHT = 'TotalWeight';
    public static final Set<String> UK_IMAGE_LEVELS = new Set<String>{'Iconic','Leading','Premium','Mainstream Quality','Mainstream Standard'};
    public static final Set<String> DEFAULT_IMAGE_LEVELS = new Set<String>{'Iconic','Leading','Premium','Mainstream'};
   // public static String countryCode;
    
    private static Boolean isPRT = false;
    public static EUR_CRM_Pros_Segmentation__c returnProsSegmentationviaId(Id prosSegmentationId)
    {
        EUR_CRM_Pros_Segmentation__c prosSegmentation = [SELECT Id, RecordTypeId,
                            EUR_CRM_Account__c,
                            EUR_CRM_Account__r.EUR_CRM_Image_Level_Name__c,
                            EUR_CRM_Standard_Account__c,
                            EUR_CRM_Affiliate__c, 
                            EUR_CRM_Affiliate__r.EUR_CRM_Decision_Tree__c,
                            EUR_CRM_Affiliate__r.Name,
                            EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Image_Level__c, 
                            EUR_CRM_Outlet_Type__c, 
                            EUR_CRM_Volume_Potential__c,
                            EUR_CRM_Service_Pack__c,
                            EUR_CRM_Decision_Tree__c,
                            EUR_CRM_Group_Outlet_Type__r.Name, EUR_CRM_Outlet_Type__r.Name, EUR_CRM_Image_Level__r.Name, EUR_CRM_Volume_Potential__r.Name,
                            EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Name__c, 
                            EUR_CRM_Country_Code__c, 
                            EUR_CRM_Volume_Potential__r.EUR_CRM_Name__c, 
                            EUR_CRM_Image_Level__r.EUR_CRM_Name__c, EUR_CRM_Volume_Potential_Threshold__r.EUR_CRM_Volume_Potential_Name__c,
                            EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c //Baltics - added new fields on the query
                            FROM EUR_CRM_Pros_Segmentation__c 
                            WHERE Id=:prosSegmentationId
                            LIMIT 1];
        if(prosSegmentation != null && prosSegmentation.eur_crm_country_code__c == 'PRT')
            isPRT = true;            
        System.debug('Flag - Pros Segmentation via ID:' + prosSegmentation);   
        return prosSegmentation;
    }
    
    public static List<String> returnImageLevelLabels()
    {
        
        /*Id gbId = [Select Id from RecordType Where SobjectType = 'EUR_CRM_Image_Level__c' 
                                            AND DeveloperName like 'EUR_GB_Image_Level'].Id;
        EUR_CRM_Image_Level__c ilevelList = [Select Id, EUR_CRM_Name__c from EUR_CRM_Image_Level__c where RecordType.DeveloperName like 'EUR_GB_Image_Level'];
        system.debug('$%$%' + iLevelList);
        
         */
                                     
        List<String> imageLabels = new List<String>();
        Schema.DescribeFieldResult fieldResult = EUR_CRM_Image_Level__c.EUR_CRM_Name__c.getDescribe();
        System.debug('Describe Field: ' + fieldResult);
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();

        for(Schema.PicklistEntry image: values){
                imageLabels.add(image.getValue());
        }
        
        
        

        return imageLabels;
    }
    
    public static List<String> returnImageLevelLabels(String countryCode)
    {
          
        List<String> imageLabels = new List<String>();
        Schema.DescribeFieldResult fieldResult = EUR_CRM_Image_Level__c.EUR_CRM_Name__c.getDescribe();
        system.debug('++ countryCode: ' + countryCode); 
        for(Schema.PicklistEntry tempPle : fieldResult.getPicklistValues()){
            String val = tempPle.getValue();
                    if(countryCode == 'UK' || countryCode == 'GB'){
                        if(EUR_CRM_ProsSegmentationClass.UK_IMAGE_LEVELS.contains(val)){
                            imageLabels.add(val);
                        }
                    }else{
                        if(EUR_CRM_ProsSegmentationClass.DEFAULT_IMAGE_LEVELS.contains(val)){
                            imageLabels.add(val);
                        }
                    }
         }
        return imageLabels;
    }
    
    public static List<String> returnVolumePotentialLabels()
    {
        List<String> volumeLabels = new List<String>();
        Schema.DescribeFieldResult fieldResult = EUR_CRM_Volume_Potential__c.EUR_CRM_Name__c.getDescribe();
        System.debug('Describe Field: ' + fieldResult);
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry vol: values){
                volumeLabels.add(vol.getValue());
        }
        return volumeLabels;
    }

    public static Map<String, Boolean> returnImageVolumeMatrix(EUR_CRM_Pros_Segmentation__c prosSegmentation)
    {
        Map<String, Boolean> imageVolumeMap = new Map<String, Boolean>();
        //List<String>imageLevelLabels = new List<String>();
        //List<String>volumePotentialLabels = new List<String>();
                
        List<String> imageLabels = returnImageLevelLabels();
        List<String> volumeLabels = returnVolumePotentialLabels();
        system.debug('%%ImageLevel'+imageLabels);
         system.debug('%%volumeLabels'+volumeLabels);
        //for(Schema.PicklistEntry vol: volumeLabels){
        //        volumePotentialLabels.add(vol.getValue());
        //}
        system.debug('@@@Pros Seg Class' + imageLabels);
        for (String image: imageLabels){
                for(String vol: volumeLabels){
                        if(image.equalsIgnoreCase(prosSegmentation.EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c) && vol.equalsIgnoreCase(prosSegmentation.EUR_CRM_Volume_Potential_Threshold__r.EUR_CRM_Volume_Potential_Name__c)){
                            imageVolumeMap.put(image+vol, true);
                        }else{
                            imageVolumeMap.put(image+vol, false);
                        }
                        /*
                        
                        system.debug('%%VOLPOT::' + this.prosSegmentation.EUR_CRM_Volume_Potential_Threshold__c);
                        if(this.prosSegmentation!= null && image.getValue().equalsIgnoreCase(this.prosSegmentation.EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c) && 
                        vol.getValue().equalsIgnoreCase(this.prosSegmentation.EUR_CRM_Volume_Potential_Threshold__r.EUR_CRM_Volume_Potential_Name__c)){
                                imageVolumeMap.put(image.getValue()+vol.getValue(), true);
                        }else{
                        imageVolumeMap.put(image.getValue()+vol.getValue(), false);}*/
                }
                //imageLevelLabels.add(image.getValue());
        }
        system.debug('@@@Image Vol Map' + imageVolumeMap);
        return imageVolumeMap;
    }
    
    public static List<EUR_CRM_Image_Level_Threshold__c> returnImageLevels(String groupOutletType)
    {
        System.debug('ImageLevelThreshold query - groupOutlet Type:' + groupOutletType);
        /*List<EUR_CRM_Image_Level__c> imageLevelThresholds = new List<EUR_CRM_Image_Level__c>();
        imageLevelThresholds = [SELECT Id, EUR_CRM_Name__c, EUR_CRM_Min_Weight__c 
                                FROM EUR_CRM_Image_Level__c
                                WHERE EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Name__c=: groupOutletType
                                ORDER BY EUR_CRM_Min_Weight__c];
        System.debug('ImageLevelThreshold query - groupOutlet Type:' + groupOutletType);*/
        
        List<EUR_CRM_Image_Level_Threshold__c> imageLevelThresholds = new List<EUR_CRM_Image_Level_Threshold__c>();
        imageLevelThresholds = [SELECT Id, EUR_CRM_Min_Weight__c 
                                FROM EUR_CRM_Image_Level_Threshold__c
                                WHERE EUR_CRM_Group_Outlet_Type__c =: groupOutletType
                                ORDER BY EUR_CRM_Min_Weight__c];
                                
        system.debug('@@imageLevelThresholds' + imageLevelThresholds);
        System.debug('ImageLevelThreshold query - groupOutlet Type:' + groupOutletType);
        
        return imageLevelThresholds;
    }

    public static List<EUR_CRM_Volume_Potential_Threshold__c> returnVolumePotential(String groupOutletType)
    {
        /*List<EUR_CRM_Volume_Potential__c> volumePotentialThresholds = new List<EUR_CRM_Volume_Potential__c>();
        volumePotentialThresholds = [SELECT Id, EUR_CRM_Name__c, EUR_CRM_Min_Weight__c 
                                FROM EUR_CRM_Volume_Potential__c
                                WHERE EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Name__c =: groupOutletType
                                ORDER BY EUR_CRM_Min_Weight__c];*/
        List<EUR_CRM_Volume_Potential_Threshold__c> volumePotentialThresholds = new List<EUR_CRM_Volume_Potential_Threshold__c>();
        volumePotentialThresholds = [SELECT Id, EUR_CRM_Min_Weight__c 
                                FROM EUR_CRM_Volume_Potential_Threshold__c
                                WHERE EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Name__c =: groupOutletType
                                ORDER BY EUR_CRM_Min_Weight__c];
        return volumePotentialThresholds;
    }
    
    public static Id returnServicePackId(EUR_CRM_Pros_Segmentation__c prosSegmentation){
        Id servicePackId = null;
                

        if((prosSegmentation!=null) && (prosSegmentation.EUR_CRM_Service_Pack__c != null)){
            servicePackId = prosSegmentation.EUR_CRM_Service_Pack__c;
        }
        //else if ((prosSegmentation!=null) && (prosSegmentation.EUR_CRM_Group_Outlet_Type__c!=null) && (prosSegmentation.EUR_CRM_Image_Level__c!=null)){
        else if ((prosSegmentation!=null) && (prosSegmentation.EUR_CRM_Group_Outlet_Type__c!=null) && (prosSegmentation.EUR_CRM_Image_Level_Threshold__c!=null || (prosSegmentation.EUR_CRM_Account__r != null && prosSegmentation.EUR_CRM_Account__r.EUR_CRM_Image_Level_Name__c != null ))){
            EUR_CRM_Service_Pack__c tempServicePack = retrieveServicePack(prosSegmentation);

            if(tempServicePack!=null){
                servicePackId = tempServicePack.Id;
            }
        }
        //prosSegmentation.EUR_CRM_Service_Pack__c = servicePackId;

        return servicePackId;
    }
    
    public static EUR_CRM_Service_Pack__c retrieveServicePack(EUR_CRM_Pros_Segmentation__c prosSegmentation)
    {
        //Baltics - Modified query to support Country specific  
        System.debug('Flag - Retrieve Service Pack - Check Pros:' + prosSegmentation +'--'+
                    prosSegmentation.EUR_CRM_Country_Code__c +'--'+
                    prosSegmentation.EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Name__c+'--'+
                    prosSegmentation.EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c);
        //Edit: 10/14 - Changed source of Image Level from Image Level Threshold to Account, to support Force Iconic
        //Edit: 11/06 - Retained use of Image Level Threshold for PRT
        String imageLevelName = (prosSegmentation.EUR_CRM_Country_Code__c=='PRT')?prosSegmentation.EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c:prosSegmentation.EUR_CRM_Account__r.EUR_CRM_Image_Level_Name__c;
        List<EUR_CRM_Service_Pack__c> tempServicePack = [SELECT Id, //EUR_CRM_Affiliate__c, 
                                                    EUR_CRM_Outlet_Type__c,
                                                    EUR_CRM_Segmentation__c,
                                                    EUR_CRM_Country_Code__c
                                                    FROM EUR_CRM_Service_Pack__c 
                                                    WHERE EUR_CRM_Country_Code__c =: prosSegmentation.EUR_CRM_Country_Code__c 
                                                    AND EUR_CRM_Outlet_Type__c =: prosSegmentation.EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Name__c
                                                    AND EUR_CRM_Segmentation__c =: imageLevelName];//EUR_CRM_Image_Level__r.EUR_CRM_Name__c LIMIT 1];
                                                 //   AND EUR_CRM_Segmentation__c =: prosSegmentation.EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c];//EUR_CRM_Image_Level__r.EUR_CRM_Name__c LIMIT 1];
                                                    //WHERE EUR_CRM_Affiliate__c =: prosSegmentation.EUR_CRM_Affiliate__c
                                                    //AND  EUR_CRM_Outlet_Type__c=: prosSegmentation.EUR_CRM_Group_Outlet_Type__c
                                                    //AND EUR_CRM_Segmentation__c=: prosSegmentation.EUR_CRM_Image_Level__c
                                                    //LIMIT 1];
        if(tempServicePack.size()>0){
            return tempServicePack[0];
        }
        return null;
    }
    
    public static void resetProsSegmentation(EUR_CRM_Pros_Segmentation__c prosSegmentation)
    {   
        //Reset Pros Segmentation base on new Group Outlet Type value
        if (prosSegmentation !=null){
            System.Savepoint pSavepoint = Database.setSavepoint();
            
            prosSegmentation.EUR_CRM_Service_Pack__c = null;
            //prosSegmentation.EUR_CRM_Image_Level__c = null;
            //prosSegmentation.EUR_CRM_Volume_Potential__c = null;
            prosSegmentation.EUR_CRM_Image_Level_Threshold__c = null;
            prosSegmentation.EUR_CRM_Volume_Potential_Threshold__c = null;
            
            try{
                Database.SaveResult updateResult;
                Database.Deleteresult[] deleteImageLevelResults;
                Database.Deleteresult[] deleteVolumePotentialResults;
                
                List<EUR_CRM_Pros_Image_Level__c> tempImageLevels = [SELECT Id 
                                                            from EUR_CRM_Pros_Image_Level__c 
                                                            WHERE EUR_CRM_Pros_Segmentation__c =:prosSegmentation.Id];
                //get Prod Volume Potential
                List<EUR_CRM_Pros_Volume_Potential__c> tempVolumePotentials = [SELECT Id 
                                                                from EUR_CRM_Pros_Volume_Potential__c 
                                                                WHERE EUR_CRM_Pros_Segmentation__c =:prosSegmentation.Id];
    
                System.debug('EUR_CRM_ProsSegmentationClass UPDATE RESULT: ' + updateResult);
                if(tempImageLevels.size()>0){
                    deleteImageLevelResults = Database.delete(tempImageLevels);
                }
                System.debug('EUR_CRM_ProsSegmentationClass DELETE IMGAE RESULT: ' + deleteImageLevelResults);
                if(deleteVolumePotentialResults.size()>0){
                    deleteVolumePotentialResults = Database.delete(tempVolumePotentials);
                }
                System.debug('EUR_CRM_ProsSegmentationClass DELETE VOLUME RESULT: ' + deleteVolumePotentialResults);
                updateResult = Database.update(prosSegmentation);
            }
            catch(Exception e){
                System.debug('EUR_CRM_ProsSegmentationClass Update Error: ' + e);
                Database.rollback(pSavepoint);                  
            }
        }
    }
    
    public static void resetServicePack(EUR_CRM_Pros_Segmentation__c prosSegmentation)
    {
        if (prosSegmentation != null){
            System.Savepoint pSavepoint = Database.setSavepoint();
            
            prosSegmentation.EUR_CRM_Service_Pack__c = null;
            
            Map<String, EUR_CRM_Service_Pack__c> spMap = new Map<String, EUR_CRM_Service_Pack__c>();
            EUR_CRM_Service_Pack__c servicePack =  retrieveServicePack(prosSegmentation);
                                                                
            System.debug('Flag - ServicePack: ' + servicePack);
            
            if(servicePack!=null){
                prosSegmentation.EUR_CRM_Service_Pack__c = servicePack.Id;
            }
            
            try{
                Database.SaveResult updateResult;
                System.debug('Flag - Update Pros Seg: ' + prosSegmentation);
                updateResult = Database.update(prosSegmentation);
            }
            catch(Exception e){
                System.debug('EUR_CRM_ProsSegmentationClass Update Error: ' + e);
                Database.rollback(pSavepoint);                
            }
        }
    }
    

    public static EUR_CRM_Affiliate__c returnAffiliate()
    {
        EUR_CRM_Affiliate__c affiliate = null;
        User activeUser = [SELECT CompanyName FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
        if (activeUser != null && activeUser.CompanyName != null){
            List<EUR_CRM_Affiliate__c> tempAffiliate = null;
            tempAffiliate = [SELECT Id, Name, EUR_CRM_Decision_Tree__c
                            from EUR_CRM_Affiliate__c 
                            WHERE Name=:activeUser.CompanyName];
                            
            if(tempAffiliate!=null)
                affiliate = tempAffiliate[0];
        }
        
        return affiliate;
    }
    
    public static Integer returnSuperPremium(Id accountId){
        Integer totalSuperUltraPremium = 0;
        
        List<EUR_CRM_ID_Card__c> idCard = [SELECT Id, EUR_CRM_Total_Super_Ultra_Brands__c
                                        FROM EUR_CRM_ID_Card__c WHERE EUR_CRM_Outlet__c=:accountId 
                                        LIMIT 1];
        if(idCard.size()>0){
            totalSuperUltraPremium = Integer.valueOf(idCard[0].EUR_CRM_Total_Super_Ultra_Brands__c);
        }
        
        return totalSuperUltraPremium;
    }
    
    //FOR TRIGGER
    public static void processCriteriaSheetModification(Set<Id> criteriaSet)
    {
        List<EUR_CRM_Group_Outlet_Type__c> groupOutletList = new List<EUR_CRM_Group_Outlet_Type__c>();
        Set<Id> affiliateSet  = new Set<Id>();
        Set<Id> groupOutletNameSet = new Set<Id>();
        
        List<EUR_CRM_Pros_Segmentation__c>prosSegmentationList  = new List<EUR_CRM_Pros_Segmentation__c>();
        Map<String, List<EUR_CRM_Pros_Segmentation__c>> prosSegmentationMap = new Map<String, List<EUR_CRM_Pros_Segmentation__c>>();
        Map<String, EUR_CRM_Pros_Segmentation__c> updatedProsSegmentation = new Map<String, EUR_CRM_Pros_Segmentation__c>();
        
        //Process selected criteria set
        //Get group outlet type
        for (EUR_CRM_Group_Outlet_Type__c groupOutlet : [SELECT Id, EUR_CRM_Group_Outlet_Name__c, EUR_CRM_Affiliate__c,  
                                                        EUR_CRM_Country_Code__c,
                                                        EUR_CRM_Image_Criteria_Set__c, EUR_CRM_Volume_Criteria_Set__c
                                                        FROM EUR_CRM_Group_Outlet_Type__c
                                                        WHERE EUR_CRM_Image_Criteria_Set__c IN: criteriaSet
                                                        OR EUR_CRM_Volume_Criteria_Set__c IN: criteriaSet LIMIT 49999])
        {
            groupOutletList.add(groupOutlet);
            groupOutletNameSet.add(groupOutlet.Id);
        }
        
        if (groupOutletList.size()>0)
        {            
            //Get Pros Segmentation
            /*prosSegmentationList = [SELECT Id, EUR_CRM_Affiliate__c, EUR_CRM_Group_Outlet_Type__c,
                                    EUR_CRM_Is_Image_Level_Modified__c, EUR_CRM_Is_Volume_Potential_Modified__c
                                    FROM EUR_CRM_Pros_Segmentation__c
                                    WHERE EUR_CRM_Affiliate__c IN: affiliateSet 
                                    AND EUR_CRM_Group_Outlet_Type__c IN:groupOutletNameSet];*/
            //Generate Pros Segmentation Map (Key: EUR_CRM_Affiliate__c + EUR_CRM_Group_Outlet_Type__c)                     
            for(EUR_CRM_Pros_Segmentation__c prosSeg: [SELECT Id, EUR_CRM_Affiliate__c, 
                                    EUR_CRM_Country_Code__c,
                                    EUR_CRM_Group_Outlet_Type__c,
                                    EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Image_Criteria_Set__c,
                                    EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Volume_Criteria_Set__c,
                                    EUR_CRM_Is_Image_Level_Modified__c, EUR_CRM_Is_Volume_Potential_Modified__c
                                    FROM EUR_CRM_Pros_Segmentation__c
                                    WHERE EUR_CRM_Group_Outlet_Type__c IN:groupOutletNameSet
                                    LIMIT 49999])
            {
                //String key = prosSeg.EUR_CRM_Affiliate__c + prosSeg.EUR_CRM_Group_Outlet_Type__c;
                /*
                String key = prosSeg.EUR_CRM_Country_Code__c + String.valueOf(prosSeg.EUR_CRM_Group_Outlet_Type__c);
                List<EUR_CRM_Pros_Segmentation__c> prosList = (prosSegmentationMap.containskey(key)?prosSegmentationMap.get(key):new List<EUR_CRM_Pros_Segmentation__c>());
                prosList.add(prosSeg);
                prosSegmentationMap.put(key, prosList);
                */
                prosSeg.EUR_CRM_Is_Image_Level_Modified__c = (criteriaSet.contains(prosSeg.EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Image_Criteria_Set__c))?true:prosSeg.EUR_CRM_Is_Image_Level_Modified__c;
                prosSeg.EUR_CRM_Is_Volume_Potential_Modified__c = (criteriaSet.contains(prosSeg.EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Volume_Criteria_Set__c))?true:prosSeg.EUR_CRM_Is_Volume_Potential_Modified__c;
                        
                updatedProsSegmentation.put(prosSeg.Id, prosSeg);

            }
            /*
            if (prosSegmentationMap.size()>0)
            {
                for (EUR_CRM_Group_Outlet_Type__c groupOutlet: groupOutletList)
                {
                    String key = groupOutlet.EUR_CRM_Country_Code__c + groupOutlet.EUR_CRM_Group_Outlet_Name__c;
                    if(prosSegmentationMap.containsKey(key)){
                        for(EUR_CRM_Pros_Segmentation__c prosSeg: prosSegmentationMap.get(key))
                        {
                            EUR_CRM_Pros_Segmentation__c updateProsSeg = (updatedProsSegmentation.containsKey(prosSeg.Id))?updatedProsSegmentation.get(prosSeg.Id):prosSeg;
                            
                            updateProsSeg.EUR_CRM_Is_Image_Level_Modified__c = (criteriaSet.contains(groupOutlet.EUR_CRM_Image_Criteria_Set__c))?true:prosSeg.EUR_CRM_Is_Image_Level_Modified__c;
                            updateProsSeg.EUR_CRM_Is_Volume_Potential_Modified__c = (criteriaSet.contains(groupOutlet.EUR_CRM_Volume_Criteria_Set__c))?true:prosSeg.EUR_CRM_Is_Volume_Potential_Modified__c;
                        
                            updatedProsSegmentation.put(prosSeg.Id, updateProsSeg);
                        }
                    }
                }
            }*/
        }
        
        //Update Pros Segmentation
        if (updatedProsSegmentation.size()>0){
            System.Savepoint pSavepoint = Database.setSavepoint();
            try{
                Database.SaveResult[] updateResults;
                
                System.debug('Flag - Pros Seg for Update: ' + updatedProsSegmentation);
                updateResults = Database.update(updatedProsSegmentation.values());
                
                System.debug('Update Result: ' + updateResults);
            }
            catch(Exception e)
            {
                System.debug('Update Error: ' + e);
                Database.rollback(pSavepoint);      
            }
        }
    }
    
    /*********************************************************************
        FOR TRIGGER: EUR_CRM_CriteriaAnswerTrigger
        Description: Edit / Remove Answer Value of a picklist criteria
    *********************************************************************/
    public static void processPicklistCriteriaSheetModification(Set<Id> criteriaSet, Map<Id, List<EUR_CRM_Criteria_Answer__c>> criteriaThresholds){
        List<EUR_CRM_Group_Outlet_Type__c> groupOutletList = new List<EUR_CRM_Group_Outlet_Type__c>();
        Set<Id> groupOutletNameSet = new Set<Id>();
        
        List<EUR_CRM_Pros_Segmentation__c>prosSegmentationList  = new List<EUR_CRM_Pros_Segmentation__c>();
        Map<String, List<EUR_CRM_Pros_Segmentation__c>> prosSegmentationMap = new Map<String, List<EUR_CRM_Pros_Segmentation__c>>();
        Map<String, EUR_CRM_Pros_Segmentation__c> updatedProsSegmentation = new Map<String, EUR_CRM_Pros_Segmentation__c>();
        
        //Process selected criteria set
        //Get group outlet type
        for (EUR_CRM_Group_Outlet_Type__c groupOutlet : [SELECT Id, EUR_CRM_Group_Outlet_Name__c, EUR_CRM_Affiliate__c,  
                                                        EUR_CRM_Country_Code__c,
                                                        EUR_CRM_Image_Criteria_Set__c, EUR_CRM_Volume_Criteria_Set__c
                                                        FROM EUR_CRM_Group_Outlet_Type__c
                                                        WHERE EUR_CRM_Image_Criteria_Set__c IN: criteriaSet
                                                        OR EUR_CRM_Volume_Criteria_Set__c IN: criteriaSet LIMIT 49999]){
            groupOutletList.add(groupOutlet);
            groupOutletNameSet.add(groupOutlet.Id);
        }
        
        if (groupOutletList.size()>0){
            /************************
            PROS Image Level
            ************************/
            List<EUR_CRM_Pros_Image_Level__c> pImageLevelList = new List<EUR_CRM_Pros_Image_Level__c>();
            for(EUR_CRM_Pros_Image_Level__c pil :[Select Id, EUR_CRM_Answer__c, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Statement__c
                                                    From EUR_CRM_Pros_Image_Level__c 
                                                    Where EUR_CRM_Criteria_Threshold__c IN: criteriaThresholds.keySet()]){
                pImageLevelList.add(pil);
            }
            system.debug('***pImageLevelList: ' + pImageLevelList);
            Set<Id> prosSegImageStatus = new Set<Id>();
            if(pImageLevelList.size() > 0){
                for(EUR_CRM_Pros_Image_Level__c pIL :pImageLevelList){
                    for(EUR_CRM_Criteria_Answer__c ca :criteriaThresholds.get(pIL.EUR_CRM_Criteria_Threshold__c)){
                        if(pIL.EUR_CRM_Answer__c == ca.EUR_CRM_Value__c){
                            prosSegImageStatus.add(pIL.EUR_CRM_Pros_Segmentation__c);
                        }
                    }
                }
            }
            system.debug('***prosSegImageStatus: ' + prosSegImageStatus);
            /************************
            PROS Voulume Potential
            ************************/
            List<EUR_CRM_Pros_Volume_Potential__c> pVolumePotentialList = new List<EUR_CRM_Pros_Volume_Potential__c>();
            for(EUR_CRM_Pros_Volume_Potential__c pil :[Select Id, EUR_CRM_Answer__c, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Statement__c
                                                    From EUR_CRM_Pros_Volume_Potential__c 
                                                    Where EUR_CRM_Criteria_Threshold__c IN: criteriaThresholds.keySet()]){
                pVolumePotentialList.add(pil);
            }
            system.debug('***pVolumePotentialList: ' + pVolumePotentialList);
            Set<Id> prosSegVolumeStatus = new Set<Id>();
            if(pVolumePotentialList.size() > 0){
                for(EUR_CRM_Pros_Volume_Potential__c pIL :pVolumePotentialList){
                    for(EUR_CRM_Criteria_Answer__c ca :criteriaThresholds.get(pIL.EUR_CRM_Criteria_Threshold__c)){
                        if(pIL.EUR_CRM_Answer__c == ca.EUR_CRM_Value__c){
                            prosSegVolumeStatus.add(pIL.EUR_CRM_Pros_Segmentation__c);
                        }
                    }
                }
            }
            system.debug('***prosSegVolumeStatus: ' + prosSegVolumeStatus);
            for(EUR_CRM_Pros_Segmentation__c prosSeg: [SELECT Id, EUR_CRM_Affiliate__c, 
                                    EUR_CRM_Country_Code__c,
                                    EUR_CRM_Group_Outlet_Type__c,
                                    EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Image_Criteria_Set__c,
                                    EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Volume_Criteria_Set__c,
                                    EUR_CRM_Is_Image_Level_Modified__c, EUR_CRM_Is_Volume_Potential_Modified__c
                                    FROM EUR_CRM_Pros_Segmentation__c
                                    WHERE EUR_CRM_Group_Outlet_Type__c IN:groupOutletNameSet
                                    LIMIT 49999]){
                                    
                if(prosSegImageStatus.size() > 0){
                    prosSeg.EUR_CRM_Is_Image_Level_Modified__c = (prosSegImageStatus.contains(prosSeg.Id))?true:false;
                }
                if(prosSegVolumeStatus.size() > 0){
                    prosSeg.EUR_CRM_Is_Volume_Potential_Modified__c = (prosSegVolumeStatus.contains(prosSeg.Id))?true:false;
                }
                
                //prosSeg.EUR_CRM_Is_Image_Level_Modified__c = (criteriaSet.contains(prosSeg.EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Image_Criteria_Set__c))?true:prosSeg.EUR_CRM_Is_Image_Level_Modified__c;
                //prosSeg.EUR_CRM_Is_Volume_Potential_Modified__c = (criteriaSet.contains(prosSeg.EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Volume_Criteria_Set__c))?true:prosSeg.EUR_CRM_Is_Volume_Potential_Modified__c;

                updatedProsSegmentation.put(prosSeg.Id, prosSeg);
            }
        }
        
        //Update Pros Segmentation
        if (updatedProsSegmentation.size() > 0){
            System.Savepoint pSavepoint = Database.setSavepoint();
            try{
                Database.SaveResult[] updateResults;

                System.debug('Flag - Pros Seg for Update: ' + updatedProsSegmentation);
                updateResults = Database.update(updatedProsSegmentation.values());

                System.debug('Update Result: ' + updateResults);
            }
            catch(Exception e){
                System.debug('Update Error: ' + e);
                Database.rollback(pSavepoint);      
            }
        }
    }
    
    public static EUR_CRM_ID_Card__c returnIdCard(Id accountId)
    {
        EUR_CRM_ID_Card__c idCard = null;
        if (accountId!=null){
            List<EUR_CRM_ID_Card__c> idCards = [SELECT Id  , EUR_CRM_Outlet__c//, EUR_CRM_Total_Annual_Volume__c 
                                                FROM EUR_CRM_ID_Card__c  WHERE EUR_CRM_Outlet__c=:accountId]; 
            
            if (idCards.size()>0)
                idCard = idCards[0];
            //TODO Create new ID Card - FOR VERIFICATION
        }
        return idCard;
    }
    
    public static Map<Id, EUR_CRM_ID_Card__c> returnIdCardMap(Set<Id> accountIdSet)
    {
        Map<Id, EUR_CRM_ID_Card__c> idCardMap = New Map<Id, EUR_CRM_ID_Card__c>();
        List<EUR_CRM_ID_Card__c> idCards = new List<EUR_CRM_ID_Card__c>();
        
        if (accountIdSet!=null){
            idCards = [SELECT Id  , EUR_CRM_Outlet__c//,EUR_CRM_Total_Annual_Volume__c  
                        FROM EUR_CRM_ID_Card__c WHERE EUR_CRM_Outlet__c IN:accountIdSet];  
            
            for(EUR_CRM_ID_Card__c idCard : idCards)
            {
               idCardMap.put(idCard.EUR_CRM_Outlet__c, idCard);
            }
            //TODO Create new ID Card - FOR VERIFICATION
        }
        return idCardMap;
    }
    
    public static void assignVolumePotential(List<EUR_CRM_Pros_Segmentation__c> prosSegmentationsRef, Map<Id, EUR_CRM_ID_Card__c> idCards)
    {
        String currentGroupOutletType = '';
        System.Savepoint pSavepoint = Database.setSavepoint();
            
        //List<EUR_CRM_Volume_Potential__c>volumePotentials =  new List<EUR_CRM_Volume_Potential__c>();
        //List<EUR_CRM_Volume_Potential_Threshold__c>volumePotentials =  new List<EUR_CRM_Volume_Potential_Threshold__c>();
        
        Set<Id> prosSegmentationId = new Set<Id>();
        List<EUR_CRM_Pros_Segmentation__c> updateProsSegmentations = new List<EUR_CRM_Pros_Segmentation__c>();
        List<EUR_CRM_Pros_Volume_Potential__c> newProsVolumePotential = new List<EUR_CRM_Pros_Volume_Potential__c>();
        //Map<Id, EUR_CRM_Affiliate__c> affiliates = retrieveAffiliates();
        List<EUR_CRM_Pros_Segmentation__c> prosSegmentations = new List<EUR_CRM_Pros_Segmentation__c>();
        Map<Id,  List<EUR_CRM_Volume_Potential_Threshold__c>> volumePotentialsMap = new Map<Id,  List<EUR_CRM_Volume_Potential_Threshold__c>>();
        
        try{
            if (idCards.size()>0 && prosSegmentationsRef.size()>0){
                //Get Volume Index Total
                System.debug('Flag - AssignVolPotential - ID Card Map:' + idCards);
                Set<Id> prosSegId = new Set<Id>();
                Set<Id> groupOutletSet = new Set<Id>();
                Map<Id, Double> volIndexTotalMap = retrieveIDCardVolumeIndexMap(idCards);
                EUR_CRM_ProsSegmentationManager prosMgr = new EUR_CRM_ProsSegmentationManager();
                
                EUR_CRM_Criteria_Threshold__c volPotentialCriteria = retrieveVolumePotentialCriteria();
                
                
                //Get all Group Outlet Type
                for(EUR_CRM_Pros_Segmentation__c prosSegmentation : prosSegmentationsRef){
                    if (prosSegmentation.EUR_CRM_Group_Outlet_Type__c != null)
                    {
                        prosSegId.add(prosSegmentation.Id);
                        groupOutletSet.add(prosSegmentation.EUR_CRM_Group_Outlet_Type__c);
                    }
                }
                //Get Pros Segmentation Details
                prosSegmentations = [SELECT Id, EUR_CRM_Standard_Account__c, EUR_CRM_Account__c, EUR_CRM_Country_Code__c, 
                                    EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Image_Level_Threshold__c, EUR_CRM_Is_Image_Level_Modified__c,
                                    EUR_CRM_Is_Volume_Potential_Modified__c, EUR_CRM_Outlet_Type__c, EUR_CRM_Service_Pack__c, EUR_CRM_Total_Image_Level_Weight__c,
                                    EUR_CRM_Total_Volume_Weight__c, EUR_CRM_Volume_Potential_Threshold__c FROM EUR_CRM_Pros_Segmentation__c
                                    WHERE Id IN:prosSegId LIMIT 49999];
                // Get Volume Potential Threshold
                if(groupOutletSet.size()>0){
                    for(EUR_CRM_Volume_Potential_Threshold__c volumePotential: [SELECT EUR_CRM_Min_Weight__c, EUR_CRM_Group_Outlet_Type__c 
                                    FROM EUR_CRM_Volume_Potential_Threshold__c
                                    WHERE EUR_CRM_Group_Outlet_Type__c IN:groupOutletSet
                                    ORDER BY EUR_CRM_Min_Weight__c LIMIT 49999]){
                        List<EUR_CRM_Volume_Potential_Threshold__c> volThresholdList = (volumePotentialsMap.containsKey(volumePotential.EUR_CRM_Group_Outlet_Type__c))?volumePotentialsMap.get(volumePotential.EUR_CRM_Group_Outlet_Type__c):new List<EUR_CRM_Volume_Potential_Threshold__c>();
                        volThresholdList.add(volumePotential);
                        volumePotentialsMap.put(volumePotential.EUR_CRM_Group_Outlet_Type__c, volThresholdList);
                    }
                }
                
                for (EUR_CRM_Pros_Segmentation__c prosSegmentation : prosSegmentations)
                {
                    System.debug('Flag - AssignVolPotential - Volume Potential Criteria: '+ volPotentialCriteria + '-' + idCards.containsKey(prosSegmentation.EUR_CRM_country_code__c == 'PRT'?prosSegmentation.EUR_CRM_Standard_Account__c : prosSegmentation.EUR_CRM_Standard_Account__c ) + '--' +prosSegmentation.EUR_CRM_country_code__c);
                    if ((volPotentialCriteria!=null) && (prosSegmentation.EUR_CRM_country_code__c == 'PRT') && (idCards.containsKey(prosSegmentation.EUR_CRM_Standard_Account__c))){
                        System.debug('Flag - AssignVolPotential - Calculating totalAnnualWeight');
                        //Get ID Card Info
                        EUR_CRM_ID_Card__c idCard = idCards.get(prosSegmentation.EUR_CRM_country_code__c == 'PRT'?prosSegmentation.EUR_CRM_Standard_Account__c : prosSegmentation.EUR_CRM_Account__c);
                        Double totalAnnualVol = (volIndexTotalMap.get(idCard.Id)!=null)?volIndexTotalMap.get(idCard.Id):0;//idCard.EUR_CRM_Total_Annual_Volume__c;
                        Decimal totalAnnualWeight = Decimal.valueOf(totalAnnualVol) * (volPotentialCriteria.EUR_CRM_Weight__c/100);///100;
                        
                        //Process Pros Segmentation
                        System.debug('Flag - AssignVolPotential - totals:' + idCard +'--'+totalAnnualVol+'--'+totalAnnualWeight);
                        System.debug('Flag - AssignVolPotential - Group Outlet:' + prosSegmentation.EUR_CRM_Group_Outlet_Type__c);
                        if (prosSegmentation.EUR_CRM_Group_Outlet_Type__c != null)
                        {
                            //Set Volume Potential
                            /*if (! currentGroupOutletType.equalsIgnoreCase(prosSegmentation.EUR_CRM_Group_Outlet_Type__c)){
                                currentGroupOutletType = prosSegmentation.EUR_CRM_Group_Outlet_Type__c;
                                
                                volumePotentials = [SELECT  EUR_CRM_Min_Weight__c 
                                FROM EUR_CRM_Volume_Potential_Threshold__c
                                WHERE EUR_CRM_Group_Outlet_Type__c =:currentGroupOutletType
                                ORDER BY EUR_CRM_Min_Weight__c];
                            }*/
                            List<EUR_CRM_Volume_Potential_Threshold__c> volumePotentials = (volumePotentialsMap.containsKey(prosSegmentation.EUR_CRM_Group_Outlet_Type__c))?volumePotentialsMap.get(prosSegmentation.EUR_CRM_Group_Outlet_Type__c):new List<EUR_CRM_Volume_Potential_Threshold__c>();
                            //Set Pros Segmentation 
                            System.debug('Flag - AssignVolPotential - Retrieve VP: ' + totalAnnualWeight + '|' +currentGroupOutletType+'-'+ volumePotentials);
                            prosSegmentation.EUR_CRM_Volume_Potential_Threshold__c = (volumePotentials.size()>0)?retrieveVolumePotential (totalAnnualWeight, volumePotentials):null;
                            updateProsSegmentations.add(prosSegmentation);
                        }
                        //Add Pros Segmentation for list of old Pros Volume Potential
                        prosSegmentationId.add(prosSegmentation.Id);
                        //Create New Pros Volume Potential
                        EUR_CRM_Pros_Volume_Potential__c prosVolPotential = new EUR_CRM_Pros_Volume_Potential__c();
                        prosVolPotential.EUR_CRM_Criteria_Threshold__c = volPotentialCriteria.Id;
                        prosVolPotential.EUR_CRM_Answer__c = String.valueOf(Integer.valueOf(totalAnnualVol));
                        prosVolPotential.EUR_CRM_Weight__c = totalAnnualWeight;
                        prosVolPotential.EUR_CRM_Pros_Segmentation__c = prosSegmentation.Id;
                        newProsVolumePotential.add(prosVolPotential);
                    }
                }
                
                //Delete Old Pros Volume Potential
                EUR_CRM_Pros_Volume_Potential__c[] oldVolumePotentialCriteria = [SELECT Id FROM EUR_CRM_Pros_Volume_Potential__c
                                     WHERE EUR_CRM_Pros_Segmentation__r.Id IN: prosSegmentationId]; 
                if (oldVolumePotentialCriteria.size()>0)
                    Database.delete(oldVolumePotentialCriteria);
                    
                //Insert new Pros Volume Potential
                if (newProsVolumePotential.size()>0)
                    insert newProsVolumePotential; //Database.insert(newProsVolumePotential);
                
                if(updateProsSegmentations.size()>0)
                    Database.update(updateProsSegmentations);
            }
        }
        catch(Exception e)
        {
            System.debug('Assign Volume Potential Error:' + e.getMessage() +'-'+ String.valueOf(e.getLineNumber()));
            System.debug('Assign Volume Potential Error:' + e);
            Database.rollback(pSavepoint);    
            
            throw e;  
        }
    }
    
    public static void assignImageLevel(Map<Id, EUR_CRM_Pros_Segmentation__c> prosSegmentations, Map<Id, EUR_CRM_ID_Card__c> idCards)
    {
        String currentImageLevel = '';
        System.Savepoint pSavepoint = Database.setSavepoint();
        
        List<EUR_CRM_Pros_Segmentation__c> updatedProsSegmentation = new List<EUR_CRM_Pros_Segmentation__c>();
        List<EUR_CRM_Pros_Image_Level__c> updatedProsImageLevel = new List<EUR_CRM_Pros_Image_Level__c>();
        //Map<Id, EUR_CRM_Affiliate__c> affiliates = retrieveAffiliates();
        
        try{
            if(prosSegmentations.size()>0 && idCards.size()>0)
            {
                EUR_CRM_CriteriaManager mgr = new EUR_CRM_CriteriaManager();
                EUR_CRM_ProsSegmentationManager prosMgr = new EUR_CRM_ProsSegmentationManager();
                
                Map<Id, List<EUR_CRM_Pros_Image_Level__c>> prosImageLevelMap = retrieveProsImageLevel(prosSegmentations.keySet());
                System.debug('Flag - Image Level prosImageLevelMap:' + prosImageLevelMap);
                //Map<Id, EUR_CRM_Group_Outlet_Type__c> prosGrpOutletMap = retrieveGroupOutletTypes(prosSegmentations.values());  
                        
                for(Id key: prosSegmentations.keySet()){
                    EUR_CRM_Pros_Segmentation__c prosSeg = prosSegmentations.get(key);
                    
                    if(prosSeg.EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Image_Criteria_Set__c != null){
                        EUR_CRM_Criteria_Threshold__c imageLevelCriteria = retrieveImageLevelCriteria(prosSeg.EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Image_Criteria_Set__c);
                        System.debug('Flag - Image Level Criteria Thresholds:' + imageLevelCriteria);
                    
                        Map<Id, List<EUR_CRM_Criteria_Answer__c>> imageLevelCriteriaAnswers = retrieveCriteriaAnswers(imageLevelCriteria);
                        
                        List<EUR_CRM_Pros_Image_Level__c> prosImageLevel = prosImageLevelMap.get(key);
                        EUR_CRM_Pros_Image_Level__c selectedProsImage = findCriteriaThresholdInPros (imageLevelCriteria.Id, prosImageLevel);
                        System.debug('Flag - Assign Image Level Checker: '+key+'|'+selectedProsImage + '|' + idCards.containsKey(prosSeg.EUR_CRM_Account__c)+'|'+imageLevelCriteriaAnswers);
                        
                        if((selectedProsImage!=null) && (idCards.containsKey(prosSeg.EUR_CRM_country_code__c == 'PRT'?prosSeg.EUR_CRM_Standard_Account__c : prosSeg.EUR_CRM_Account__c)) && (imageLevelCriteriaAnswers.size()>0)){
                            //Get old weight
                            Double totalImageLevelWeight = prosSeg.EUR_CRM_Total_Image_Level_Weight__c;
                            Double tempImageLevelWeight = totalImageLevelWeight - selectedProsImage.EUR_CRM_Weight__c;
                            String answer = String.valueOf(idCards.get(prosSeg.EUR_CRM_country_code__c == 'PRT'?prosSeg.EUR_CRM_Standard_Account__c : prosSeg.EUR_CRM_Account__c).EUR_CRM_Total_Super_Ultra_Brands__c);
                            
                            System.debug('Flag - Assignment Image Level - Answer:' + answer);
                            //Calculate new weight
                            Double answerWeight = mgr.newClassInstance(
                                imageLevelCriteria.RecordTypeId).calculateCriteria(Double.valueOf(imageLevelCriteria.EUR_CRM_Weight__c), 
                                                                            imageLevelCriteriaAnswers.get(imageLevelCriteria.Id), 
                                                                            answer);
                            
                            Double newTotalImageLevelWeight = tempImageLevelWeight + answerWeight;
                            Id imageLevel = retrieveImageLevel(newTotalImageLevelWeight, returnImageLevels(prosSeg.EUR_CRM_Group_Outlet_Type__c));
                            
                            //Set New Values
                            selectedProsImage.EUR_CRM_Weight__c = answerWeight;
                            selectedProsImage.EUR_CRM_Answer__c = answer;
                            updatedProsImageLevel.add(selectedProsImage);
                            
                            if(imageLevel!=null){
                                prosSeg.EUR_CRM_Image_Level_Threshold__c = imageLevel;
                                updatedProsSegmentation.add(prosSeg);
                            }
                        }
                    }
                }
                
                System.debug('Flag - Assign Image Level: ' + updatedProsImageLevel + '|' + updatedProsSegmentation);
                if(updatedProsImageLevel.size()>0)
                    Database.update(updatedProsImageLevel);
                
                if(updatedProsSegmentation.size()>0)
                    Database.update(updatedProsSegmentation);
            }
        }
        catch(Exception e)
        {
            System.debug('Assign Image Level:' + e.getMessage() +'|'+ String.valueOf(e.getLineNumber()));
            Database.rollback(pSavepoint);    
            
            throw e;  
        }
    }
    
    public static Id retrieveImageLevel (Double score, List<EUR_CRM_Image_Level_Threshold__c> imageLevels){
        
        //List<EUR_CRM_Image_Level__c>imageLevels = this.getImageLevelThresholds(groupOutletType);
        Id imageId = null;
        //Id imageLevelId;
        
        if(imageLevels.size()>0){
            if (score > imageLevels[imageLevels.size()-1].EUR_CRM_Min_Weight__c){
                imageId = imageLevels[imageLevels.size()-1].Id;
            }else{
                for (Integer i=0; i<imageLevels.size(); i++){
                    Double left = imageLevels[i].EUR_CRM_Min_Weight__c;
                    Double right = imageLevels[i].EUR_CRM_Min_Weight__c;
                    if (imageLevels.size()-1 != i)
                        right = imageLevels[i+1].EUR_CRM_Min_Weight__c;
                
                    if(left == score || score<right) 
                    {
                        //System.debug('1 - '+n+':' + x +'('+s[x]+')'); break;
                        imageId = imageLevels[i].Id;
                        break;
                    }
                    else if (score>right)
                    {
                        continue;
                    }
                }
            }
        }
        System.debug('Flag - Retrieve Image Level:' + imageId);
        return imageId;
    }

    public static String retrieveVolumePotential (Decimal score, List<EUR_CRM_Volume_Potential_Threshold__c> volumePotentials){
        String volumeLevel = null;
        
        if(volumePotentials.size()>0){
            if (score > volumePotentials[volumePotentials.size()-1].EUR_CRM_Min_Weight__c){
                volumeLevel = volumePotentials[volumePotentials.size()-1].Id;
            }else{
                for (Integer i=0; i<volumePotentials.size(); i++){
                    Double left = volumePotentials[i].EUR_CRM_Min_Weight__c;
                    Double right = volumePotentials[i].EUR_CRM_Min_Weight__c;
                    if (volumePotentials.size()-1 != i)
                        right = volumePotentials[i+1].EUR_CRM_Min_Weight__c;
                
                    if(left == score || score<right) 
                    {
                        //System.debug('1 - '+n+':' + x +'('+s[x]+')'); break;
                        volumeLevel = volumePotentials[i].Id;
                        break;
                    }
                    else if (score>right)
                    {
                        continue;
                    }
                }
            }
        }
        
        System.debug('Flag - Retrieve Volume Potential:'+volumeLevel+'-'+ score +' - '+volumePotentials);
        return volumeLevel;
    }
    
    public static EUR_CRM_Criteria_Threshold__c retrieveVolumePotentialCriteria()
    {
        EUR_CRM_Criteria_Threshold__c volPotentialCriteria = null;
        List<EUR_CRM_Criteria_Threshold__c> tempVolCriterias = [SELECT Id, EUR_CRM_Criteria_Set__c, 
                                                            EUR_CRM_Criteria_Type__c, EUR_CRM_Question__c, 
                                                            EUR_CRM_Weight__c 
                                                            FROM EUR_CRM_Criteria_Threshold__c
                                                            WHERE EUR_CRM_Question__c=:VOLUME_POTENTIAL_STATEMENT
                                                            LIMIT 1];
        if (tempVolCriterias.size()>0)
            volPotentialCriteria = tempVolCriterias[0];
        
        return  volPotentialCriteria;                                               
    }
    
    public static Map<Id, Double> retrieveIDCardVolumeIndexMap(Map<Id, EUR_CRM_ID_Card__c> idCards)
    {
        Map<Id, Double> idCardVolumeIndexMap = new Map<Id, Double>();
        
        Set<Id> idCardKeys = new Set<Id>();
        for(Id key: idCards.keySet()){
            idCardKeys.add(idCards.get(key).Id);
        }                                                   
        AggregateResult[] groupedResults = [SELECT EUR_CRM_ID_Card__c, SUM(EUR_CRM_Annual_Volume_Index_X__c) 
                                            FROM EUR_CRM_ID_Card_Volume__c 
                                            WHERE EUR_CRM_ID_Card__c in:idCardKeys
                                            GROUP BY EUR_CRM_ID_Card__c];
        
        System.debug('flag - ID Card Volume:' + groupedResults);
        
        for (AggregateResult ar : groupedResults)  {
            idCardVolumeIndexMap.put(String.valueOf(ar.get('EUR_CRM_ID_Card__c')), Double.valueOf(ar.get('expr0')));
            //System.debug('Campaign ID' + ar.get('CampaignId'));
            //System.debug('Average amount' + ar.get('expr0'));
        }
        
        System.debug('FLAG - ID CARD VOL INDEX: ' + idCardVolumeIndexMap);
        return idCardVolumeIndexMap;
    }
    
        
    public static EUR_CRM_Criteria_Threshold__c retrieveImageLevelCriteria(Id criteriaSetId)
    {
        EUR_CRM_Criteria_Threshold__c imageLevelCriteria = null;
        List<EUR_CRM_Criteria_Threshold__c> tempImageLevelCriteria = [SELECT Id, EUR_CRM_Criteria_Set__c, 
                                                            EUR_CRM_Criteria_Type__c, EUR_CRM_Question__c, 
                                                            EUR_CRM_Weight__c, RecordTypeId
                                                            FROM EUR_CRM_Criteria_Threshold__c
                                                            WHERE EUR_CRM_Question__c=:IMAGE_LEVEL_STATEMENT
                                                            AND EUR_CRM_Criteria_Set__c=:criteriaSetId
                                                            LIMIT 1];
        if (tempImageLevelCriteria.size()>0)
            imageLevelCriteria = tempImageLevelCriteria[0];
        
        return  imageLevelCriteria;                                             
    }
    
    public static Map<Id, EUR_CRM_Criteria_Threshold__c> retrieveImageLevelCriteria(List<Id> criteriaSetIds)
    {
        Map<Id, EUR_CRM_Criteria_Threshold__c> imageLevelCriterias = new Map<Id, EUR_CRM_Criteria_Threshold__c>();
        
        List<EUR_CRM_Criteria_Threshold__c> tempImageLevelCriteria = [SELECT Id, EUR_CRM_Criteria_Set__c, 
                                                            EUR_CRM_Criteria_Type__c, EUR_CRM_Question__c, 
                                                            EUR_CRM_Weight__c, RecordTypeId
                                                            FROM EUR_CRM_Criteria_Threshold__c
                                                            WHERE EUR_CRM_Question__c=:IMAGE_LEVEL_STATEMENT
                                                            AND EUR_CRM_Criteria_Set__c IN:criteriaSetIds
                                                            LIMIT 1];
        for (EUR_CRM_Criteria_Threshold__c cTreshold: tempImageLevelCriteria){
            //imageLevelCriteria = tempImageLevelCriteria[0];
            imageLevelCriterias.put(cTreshold.EUR_CRM_Criteria_Set__c, cTreshold);
        }
        
        return  imageLevelCriterias;                                                
    }
    
    public static Map<Id, List<EUR_CRM_Criteria_Answer__c>> retrieveCriteriaAnswers(EUR_CRM_Criteria_Threshold__c criteriaThreshold){
        
        Map<Id, List<EUR_CRM_Criteria_Answer__c>> criteriaAnswers = new Map<Id, List<EUR_CRM_Criteria_Answer__c>>();

        List<EUR_CRM_Criteria_Answer__c> answers = new List<EUR_CRM_Criteria_Answer__c>([SELECT Id, RecordTypeId,
                    EUR_CRM_Value__c, 
                    EUR_CRM_Base_Currency__c, EUR_CRM_Base_Integer__c,
                    EUR_CRM_Condition__c, EUR_CRM_Criteria_Threshold__r.Id,
                    EUR_CRM_Label__c, EUR_CRM_Weight__c
                    FROM EUR_CRM_Criteria_Answer__c 
                    WHERE EUR_CRM_Criteria_Threshold__r.Id =: criteriaThreshold.Id]);

        System.debug('getAnswers:'+answers);
        
        
        if (answers.size()>0)
        {
            for (EUR_CRM_Criteria_Answer__c ans: answers){
                List<EUR_CRM_Criteria_Answer__c> criteriaAnsList = new List<EUR_CRM_Criteria_Answer__c>();
                if (criteriaAnswers.containsKey(ans.EUR_CRM_Criteria_Threshold__r.Id)){
                    criteriaAnsList = criteriaAnswers.get(ans.EUR_CRM_Criteria_Threshold__r.Id);
                }
                criteriaAnsList.add(ans);
                criteriaAnswers.put(ans.EUR_CRM_Criteria_Threshold__r.Id, criteriaAnsList);
            }
        }
        System.debug('getCriteriaAnswers:'+criteriaAnswers);
        return criteriaAnswers;
    }
    
    public static Map<Id, List<EUR_CRM_Pros_Image_Level__c>> retrieveProsImageLevel(Set<Id> prosSegIdList){
        Map<Id, List<EUR_CRM_Pros_Image_Level__c>> imageLevelMap = new Map<Id, List<EUR_CRM_Pros_Image_Level__c>>();
        
        List<EUR_CRM_Pros_Image_Level__c> prosImageLevels = new List<EUR_CRM_Pros_Image_Level__c>([SELECT Id, EUR_CRM_Criteria_Threshold__c, 
                            EUR_CRM_Weight__c, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c
                            FROM EUR_CRM_Pros_Image_Level__c
                            WHERE EUR_CRM_Pros_Segmentation__c in: prosSegIdList]);
                            
        for(EUR_CRM_Pros_Image_Level__c prosImageLevel: prosImageLevels)
        {
            List<EUR_CRM_Pros_Image_Level__c> prosImageList = new List<EUR_CRM_Pros_Image_Level__c>();
            if (imageLevelMap.containsKey(prosImageLevel.EUR_CRM_Pros_Segmentation__c)){
                prosImageList = imageLevelMap.get(prosImageLevel.EUR_CRM_Pros_Segmentation__c);
            }
            prosImageList.add(prosImageLevel);
            imageLevelMap.put(prosImageLevel.EUR_CRM_Pros_Segmentation__c, prosImageList);
        }
        
        return imageLevelMap;             
    }
    
    public static EUR_CRM_Pros_Image_Level__c findCriteriaThresholdInPros (Id criteriaThresholdId, List<EUR_CRM_Pros_Image_Level__c> prosList){
        EUR_CRM_Pros_Image_Level__c foundPros = null;
        if(prosList!=null){
            for(EUR_CRM_Pros_Image_Level__c pros: prosList){
                if (pros.EUR_CRM_Criteria_Threshold__c==criteriaThresholdId){
                    foundPros = pros;
                    break;
                }
            }
        }
        
        return foundPros;
    }
    
    public static Map<Id, EUR_CRM_Group_Outlet_Type__c> retrieveGroupOutletTypes(List<EUR_CRM_Pros_Segmentation__c> prosSegmentationList)
    {
         Map<Id, EUR_CRM_Group_Outlet_Type__c> prosGroupOutletMap = new Map<Id, EUR_CRM_Group_Outlet_Type__c>(); //Id= ProsSegmentation Id
         
         List<Id> affiliateList = new List<Id>();
         Set<String> countryCodeSet = new Set<String>();
         List<String> groupOutletNameList = new List<String>();
         Map<String, EUR_CRM_Pros_Segmentation__c> prosAffiliateGroupMap= new Map<String, EUR_CRM_Pros_Segmentation__c>();
         
         for(EUR_CRM_Pros_Segmentation__c pros: prosSegmentationList){
            affiliateList.add(pros.EUR_CRM_Affiliate__c);
            countryCodeSet.add(pros.EUR_CRM_Country_Code__c);
            groupOutletNameList.add(pros.EUR_CRM_Group_Outlet_Type__c);
            //prosAffiliateGroupMap.put(pros.EUR_CRM_Affiliate__c+pros.EUR_CRM_Group_Outlet_Type__c, pros);
            prosAffiliateGroupMap.put(pros.EUR_CRM_Country_Code__c+String.valueOf(pros.EUR_CRM_Group_Outlet_Type__c), pros);//Baltics LT/LV
         }
         
         System.debug('Flag - Retrieve Group Outlet Type:' + prosAffiliateGroupMap);
         
         List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypes = new List<EUR_CRM_Group_Outlet_Type__c>(
                                    [SELECT Id, EUR_CRM_Group_Outlet_Name__c, 
                                    EUR_CRM_Country_Code__c,
                                    EUR_CRM_Image_Criteria_Set__c, 
                                    EUR_CRM_Volume_Criteria_Set__c
                                    FROM EUR_CRM_Group_Outlet_Type__c
                                    //WHERE EUR_CRM_Country_Code__c in:countryCodeSet
                                    WHERE EUR_CRM_Name__c in:groupOutletNameList]);
        
        for(EUR_CRM_Group_Outlet_Type__c grp:groupOutletTypes){
            String key = grp.EUR_CRM_Country_Code__c + grp.Id;
            if(prosAffiliateGroupMap.containsKey(key)){
                prosGroupOutletMap.put(prosAffiliateGroupMap.get(key).Id, grp);
            }
        }
        
        return prosGroupOutletMap;
    }
    
    public static Map<Id, EUR_CRM_Affiliate__c> retrieveAffiliates(){
        Map<Id, EUR_CRM_Affiliate__c> affiliates = new Map<Id, EUR_CRM_Affiliate__c>([
                                                    SELECT Id, Name,
                                                    EUR_CRM_Decision_Tree__c
                                                    FROM EUR_CRM_Affiliate__c 
                                                    LIMIT 4999]);
                                                    
        return affiliates;
    }

}