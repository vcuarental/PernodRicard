/*********************************************************************************
 * Name: ASI_CRM_TH_ProsSegmentationClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/03/2016       Introv: Twinkle LI      Cloned from ASI_CRM_TW_ProsSegmentationClass
*********************************************************************************/

public with sharing class ASI_CRM_TH_ProsSegmentationClass {
    
    private static final String VOLUME_POTENTIAL_STATEMENT = 'Potential Volume';
    public static final String IMAGE_LEVEL_STATEMENT = 'Numero de marcas Super e Ultra Premium?';
    public static final String ANSWER_WEIGHT = 'AnswerWeight';
    public static final String TOTAL_WEIGHT = 'TotalWeight';
    public static final Set<String> UK_IMAGE_LEVELS = new Set<String>{'Iconic','Leading','Premium','Mainstream Quality','Mainstream Standard'};
    public static final Set<String> DEFAULT_IMAGE_LEVELS = new Set<String>{'Iconic','Leading','Premium','Mainstream'};
   // public static String countryCode;
    
    
    public static ASI_CRM_Pros_Segmentation__c returnProsSegmentationviaId(Id prosSegmentationId)
    {
        ASI_CRM_Pros_Segmentation__c prosSegmentation = [SELECT Id, RecordTypeId,
                            ASI_CRM_SG_Account__c, ASI_CRM_SG_Customer__c,
                            ASI_CRM_SG_Customer__r.ASI_CRM_SG_Image_Level__c,
                            ASI_CRM_SG_Group_Outlet_Type__c, ASI_CRM_SG_Image_Level__c,
                            ASI_CRM_SG_Customer__r.ASI_CRM_SG_Image_Level__r.ASI_CRM_SG_Name__c,
                            ASI_CRM_SG_Outlet_Type__c,
                            ASI_CRM_SG_Volume_Potential__c,
                            ASI_CRM_SG_Service_Pack__c,
                            ASI_CRM_SG_Group_Outlet_Type__r.Name, ASI_CRM_SG_Outlet_Type__r.Name, ASI_CRM_SG_Image_Level__r.Name, 
                            ASI_CRM_SG_Volume_Potential__r.Name,
                            ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c, 
                            ASI_CRM_SG_Volume_Potential__r.ASI_CRM_SG_Name__c, 
                            ASI_CRM_SG_Image_Level__r.ASI_CRM_SG_Name__c,
                            ASI_CRM_SG_Image_Level_Threshold__c, ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level__c,
                            ASI_CRM_SG_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c,
                            ASI_CRM_SG_DAMD_Threshold__c,
                            ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Image_Criteria_Set__c,
                            ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c //Baltics - added new fields on the query
                            FROM ASI_CRM_Pros_Segmentation__c 
                            WHERE Id=:prosSegmentationId
                            LIMIT 1];
        if(prosSegmentation != null)        
        System.debug('Flag - Pros Segmentation via ID:' + prosSegmentation);   
        return prosSegmentation;
    }
    
    public static List<String> returnImageLevelLabels(){
        List<String> imageLabels = new List<String>();
        Schema.DescribeFieldResult fieldResult = ASI_CRM_Image_Level__c.ASI_CRM_SG_Name__c.getDescribe();
        for(Schema.PicklistEntry tempPle : fieldResult.getPicklistValues()){
            String val = tempPle.getValue();
            if(ASI_CRM_TH_ProsSegmentationClass.DEFAULT_IMAGE_LEVELS.contains(val)){
                            imageLabels.add(val);
            }
        }
        return imageLabels;
    }
    
    
    public static List<String> returnVolumePotentialLabels(){
        List<String> volumeLabels = new List<String>();
        Schema.DescribeFieldResult fieldResult = ASI_CRM_Volume_Potential__c.ASI_CRM_SG_Name__c.getDescribe();
        System.debug('Describe Field: ' + fieldResult);
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry vol: values){
                volumeLabels.add(vol.getValue());
        }
        return volumeLabels;
    }

    public static Map<String, Boolean> returnImageVolumeMatrix(ASI_CRM_Pros_Segmentation__c prosSegmentation){
        Map<String, Boolean> imageVolumeMap = new Map<String, Boolean>();
       
        List<String> imageLabels = returnImageLevelLabels();
        List<String> volumeLabels = returnVolumePotentialLabels();
        system.debug('%%ImageLevel'+imageLabels);
        system.debug('%%volumeLabels'+volumeLabels);       
        system.debug('@@@Pros Seg Class' + imageLabels);
        
        for (String image: imageLabels){
            for(String vol: volumeLabels){
                if(image.equalsIgnoreCase(prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c) && vol.equalsIgnoreCase(prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c)){
                    imageVolumeMap.put(image+vol, true);
                }else{
                    imageVolumeMap.put(image+vol, false);
                }
            }
        }
        system.debug('@@@Image Vol Map' + imageVolumeMap);
        return imageVolumeMap;
    }
    
    public static List<ASI_CRM_Image_Level_Threshold__c> returnImageLevels(String groupOutletType){
        System.debug('ImageLevelThreshold query - groupOutlet Type:' + groupOutletType);

        List<ASI_CRM_Image_Level_Threshold__c> imageLevelThresholds = new List<ASI_CRM_Image_Level_Threshold__c>();
        imageLevelThresholds = [SELECT Id, ASI_CRM_SG_Min_Weight__c 
                                FROM ASI_CRM_Image_Level_Threshold__c
                                WHERE ASI_CRM_SG_Group_Outlet_Type__c =: groupOutletType
                                ORDER BY ASI_CRM_SG_Min_Weight__c];
                                
        system.debug('@@imageLevelThresholds' + imageLevelThresholds);
        System.debug('ImageLevelThreshold query - groupOutlet Type:' + groupOutletType);
        
        return imageLevelThresholds;
    }

    public static List<ASI_CRM_Volume_Potential_Threshold__c> returnVolumePotential(String groupOutletType){
        List<ASI_CRM_Volume_Potential_Threshold__c> volumePotentialThresholds = new List<ASI_CRM_Volume_Potential_Threshold__c>();
        volumePotentialThresholds = [SELECT Id, ASI_CRM_SG_Min_Weight__c 
                                FROM ASI_CRM_Volume_Potential_Threshold__c
                                WHERE ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Name__c =: groupOutletType
                                ORDER BY ASI_CRM_SG_Min_Weight__c DESC];
        return volumePotentialThresholds;
    }
    
    public static Id returnServicePackId(ASI_CRM_Pros_Segmentation__c prosSegmentation){
        Id servicePackId = null;                

        if((prosSegmentation!=null) && (prosSegmentation.ASI_CRM_SG_Service_Pack__c != null)){
            servicePackId = prosSegmentation.ASI_CRM_SG_Service_Pack__c;
        }
        else if ((prosSegmentation!=null) && (prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c!=null) && (prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c!=null )){
            ASI_CRM_ServicePack__c tempServicePack = retrieveServicePack(prosSegmentation);

            if(tempServicePack!=null){
                servicePackId = tempServicePack.Id;
            }
        }
        return servicePackId;
    }
    
    public static ASI_CRM_ServicePack__c retrieveServicePack(ASI_CRM_Pros_Segmentation__c prosSegmentation){
        //Baltics - Modified query to support Country specific  
        System.debug('Flag - Retrieve Service Pack - Check Pros:' + prosSegmentation +'--'+
                    prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c+'--'+
                    prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c);
                    
        String imageLevelName = prosSegmentation.ASI_CRM_SG_Customer__r.ASI_CRM_SG_Image_Level__r.ASI_CRM_SG_Name__c;
        List<ASI_CRM_ServicePack__c> tempServicePack = [SELECT Id,
                                                    ASI_CRM_SG_Segmentation__c
                                                    FROM ASI_CRM_ServicePack__c 
                                                    WHERE ASI_CRM_SG_Outlet_Type__c =: prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c
                                                    AND ASI_CRM_SG_Segmentation__c =: imageLevelName];//ASI_CRM_Image_Level__r.ASI_CRM_SG_Name__c LIMIT 1];
        if(tempServicePack.size()>0){
            return tempServicePack[0];
        }
        return null;
    }
    
    public static void resetProsSegmentation(ASI_CRM_Pros_Segmentation__c prosSegmentation){   
        //Reset Pros Segmentation base on new Group Outlet Type value
        if (prosSegmentation !=null){
            System.Savepoint pSavepoint = Database.setSavepoint();
            
            prosSegmentation.ASI_CRM_SG_Service_Pack__c = null;
            prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c = null;
            prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c = null;
            
            try{
                Database.SaveResult updateResult;
                Database.Deleteresult[] deleteImageLevelResults;
                Database.Deleteresult[] deleteVolumePotentialResults;
                
                List<ASI_CRM_Pros_Image_Level__c> tempImageLevels = [SELECT Id 
                                                            from ASI_CRM_Pros_Image_Level__c 
                                                            WHERE ASI_CRM_SG_Pros_Segmentation__c =:prosSegmentation.Id];
                //get Prod Volume Potential
                List<ASI_CRM_Pros_Volume_Potential__c> tempVolumePotentials = [SELECT Id 
                                                                from ASI_CRM_Pros_Volume_Potential__c 
                                                                WHERE ASI_CRM_SG_Pros_Segmentation__c =:prosSegmentation.Id];
    
                if(tempImageLevels.size()>0){
                    deleteImageLevelResults = Database.delete(tempImageLevels);
                }
                if(deleteVolumePotentialResults.size()>0){
                    deleteVolumePotentialResults = Database.delete(tempVolumePotentials);
                }
                updateResult = Database.update(prosSegmentation);
            }
            catch(Exception e){
                System.debug('ASI_CRM_TH_ProsSegmentationClass Update Error: ' + e);
                Database.rollback(pSavepoint);                  
            }
        }
    }
    
    public static void resetServicePack(ASI_CRM_Pros_Segmentation__c prosSegmentation){
        if (prosSegmentation != null){
            System.Savepoint pSavepoint = Database.setSavepoint();
            
            prosSegmentation.ASI_CRM_SG_Service_Pack__c = null;
            
            Map<String, ASI_CRM_ServicePack__c> spMap = new Map<String, ASI_CRM_ServicePack__c>();
            ASI_CRM_ServicePack__c servicePack =  retrieveServicePack(prosSegmentation);
                                                                
            System.debug('Flag - ServicePack: ' + servicePack);
            
            if(servicePack!=null){
                prosSegmentation.ASI_CRM_SG_Service_Pack__c = servicePack.Id;
            }
            
            try{
                Database.SaveResult updateResult;
                System.debug('Flag - Update Pros Seg: ' + prosSegmentation);
                updateResult = Database.update(prosSegmentation);
            }
            catch(Exception e){
                System.debug('ASI_CRM_TH_ProsSegmentationClass Update Error: ' + e);
                Database.rollback(pSavepoint);                
            }
        }
    }
    
    public static Integer returnSuperPremium(Id accountId){
        Integer totalSuperUltraPremium = 0;
        
        List<ASI_CRM_ID_Card__c> idCard = [SELECT Id, ASI_CRM_SG_Total_Super_Ultra_Brands__c
                                        FROM ASI_CRM_ID_Card__c WHERE ASI_CRM_SG_Outlet__c=:accountId 
                                        LIMIT 1];
        if(idCard.size()>0){
            totalSuperUltraPremium = Integer.valueOf(idCard[0].ASI_CRM_SG_Total_Super_Ultra_Brands__c);
        }
        
        return totalSuperUltraPremium;
    }
    
    //FOR TRIGGER
    public static void processCriteriaSheetModification(Set<Id> criteriaSet){
        List<ASI_CRM_Group_Outlet_Type__c> groupOutletList = new List<ASI_CRM_Group_Outlet_Type__c>();
        Set<Id> affiliateSet  = new Set<Id>();
        Set<Id> groupOutletNameSet = new Set<Id>();
        
        List<ASI_CRM_Pros_Segmentation__c>prosSegmentationList  = new List<ASI_CRM_Pros_Segmentation__c>();
        Map<String, List<ASI_CRM_Pros_Segmentation__c>> prosSegmentationMap = new Map<String, List<ASI_CRM_Pros_Segmentation__c>>();
        Map<String, ASI_CRM_Pros_Segmentation__c> updatedProsSegmentation = new Map<String, ASI_CRM_Pros_Segmentation__c>();
        
        //Process selected criteria set
        //Get group outlet type
        for (ASI_CRM_Group_Outlet_Type__c groupOutlet : [SELECT Id, ASI_CRM_SG_Group_Outlet_Name__c,
                                                        ASI_CRM_SG_Image_Criteria_Set__c, ASI_CRM_SG_Volume_Criteria_Set__c
                                                        FROM ASI_CRM_Group_Outlet_Type__c
                                                        WHERE ASI_CRM_SG_Image_Criteria_Set__c IN: criteriaSet
                                                        OR ASI_CRM_SG_Volume_Criteria_Set__c IN: criteriaSet LIMIT 49999])
        {
            groupOutletList.add(groupOutlet);
            groupOutletNameSet.add(groupOutlet.Id);
        }
        
        if (groupOutletList.size()>0){            
            //Get Pros Segmentation                    
            for(ASI_CRM_Pros_Segmentation__c prosSeg: [SELECT Id, ASI_CRM_SG_Group_Outlet_Type__c,
                                    ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Image_Criteria_Set__c,
                                    ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Volume_Criteria_Set__c,
                                    ASI_CRM_SG_Is_Image_Level_Modified__c, ASI_CRM_SG_Is_Volume_Potential_Modified__c
                                    FROM ASI_CRM_Pros_Segmentation__c
                                    WHERE ASI_CRM_SG_Group_Outlet_Type__c IN:groupOutletNameSet
                                    LIMIT 49999]){
                prosSeg.ASI_CRM_SG_Is_Image_Level_Modified__c = (criteriaSet.contains(prosSeg.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Image_Criteria_Set__c))?true:prosSeg.ASI_CRM_SG_Is_Image_Level_Modified__c;
                prosSeg.ASI_CRM_SG_Is_Volume_Potential_Modified__c = (criteriaSet.contains(prosSeg.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Volume_Criteria_Set__c))?true:prosSeg.ASI_CRM_SG_Is_Volume_Potential_Modified__c;
                        
                updatedProsSegmentation.put(prosSeg.Id, prosSeg);

            }
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
            catch(Exception e){
                System.debug('Update Error: ' + e);
                Database.rollback(pSavepoint);      
            }
        }
    }
    
    /*********************************************************************
        FOR TRIGGER: ASI_CRM_CriteriaAnswerTrigger
        Description: Edit / Remove Answer Value of a picklist criteria
    *********************************************************************/
    public static void processPicklistCriteriaSheetModification(Set<Id> criteriaSet, Map<Id, List<ASI_CRM_Criteria_Answer__c>> criteriaThresholds){
        List<ASI_CRM_Group_Outlet_Type__c> groupOutletList = new List<ASI_CRM_Group_Outlet_Type__c>();
        Set<Id> groupOutletNameSet = new Set<Id>();
        
        List<ASI_CRM_Pros_Segmentation__c>prosSegmentationList  = new List<ASI_CRM_Pros_Segmentation__c>();
        Map<String, List<ASI_CRM_Pros_Segmentation__c>> prosSegmentationMap = new Map<String, List<ASI_CRM_Pros_Segmentation__c>>();
        Map<String, ASI_CRM_Pros_Segmentation__c> updatedProsSegmentation = new Map<String, ASI_CRM_Pros_Segmentation__c>();
        
        //Process selected criteria set
        //Get group outlet type
        for (ASI_CRM_Group_Outlet_Type__c groupOutlet : [SELECT Id, ASI_CRM_SG_Group_Outlet_Name__c,
                                                        ASI_CRM_SG_Image_Criteria_Set__c, ASI_CRM_SG_Volume_Criteria_Set__c
                                                        FROM ASI_CRM_Group_Outlet_Type__c
                                                        WHERE ASI_CRM_SG_Image_Criteria_Set__c IN: criteriaSet
                                                        OR ASI_CRM_SG_Volume_Criteria_Set__c IN: criteriaSet LIMIT 49999]){
            groupOutletList.add(groupOutlet);
            groupOutletNameSet.add(groupOutlet.Id);
        }
        
        if (groupOutletList.size()>0){
            /************************
            PROS Image Level
            ************************/
            List<ASI_CRM_Pros_Image_Level__c> pImageLevelList = new List<ASI_CRM_Pros_Image_Level__c>();
            for(ASI_CRM_Pros_Image_Level__c pil :[Select Id, ASI_CRM_SG_Answer__c, ASI_CRM_SG_Criteria_Threshold__c, ASI_CRM_SG_Pros_Segmentation__c, ASI_CRM_SG_Statement__c
                                                    From ASI_CRM_Pros_Image_Level__c 
                                                    Where ASI_CRM_SG_Criteria_Threshold__c IN: criteriaThresholds.keySet()]){
                pImageLevelList.add(pil);
            }
            system.debug('***pImageLevelList: ' + pImageLevelList);
            Set<Id> prosSegImageStatus = new Set<Id>();
            if(pImageLevelList.size() > 0){
                for(ASI_CRM_Pros_Image_Level__c pIL :pImageLevelList){
                    for(ASI_CRM_Criteria_Answer__c ca :criteriaThresholds.get(pIL.ASI_CRM_SG_Criteria_Threshold__c)){
                        if(pIL.ASI_CRM_SG_Answer__c == ca.ASI_CRM_SG_Value__c){
                            prosSegImageStatus.add(pIL.ASI_CRM_SG_Pros_Segmentation__c);
                        }
                    }
                }
            }
            system.debug('***prosSegImageStatus: ' + prosSegImageStatus);
            /************************
            PROS Voulume Potential
            ************************/
            List<ASI_CRM_Pros_Volume_Potential__c> pVolumePotentialList = new List<ASI_CRM_Pros_Volume_Potential__c>();
            for(ASI_CRM_Pros_Volume_Potential__c pil :[Select Id, ASI_CRM_SG_Answer__c, ASI_CRM_SG_Criteria_Threshold__c, ASI_CRM_SG_Pros_Segmentation__c, ASI_CRM_SG_Statement__c
                                                    From ASI_CRM_Pros_Volume_Potential__c 
                                                    Where ASI_CRM_SG_Criteria_Threshold__c IN: criteriaThresholds.keySet()]){
                pVolumePotentialList.add(pil);
            }
            system.debug('***pVolumePotentialList: ' + pVolumePotentialList);
            Set<Id> prosSegVolumeStatus = new Set<Id>();
            if(pVolumePotentialList.size() > 0){
                for(ASI_CRM_Pros_Volume_Potential__c pIL :pVolumePotentialList){
                    for(ASI_CRM_Criteria_Answer__c ca :criteriaThresholds.get(pIL.ASI_CRM_SG_Criteria_Threshold__c)){
                        if(pIL.ASI_CRM_SG_Answer__c == ca.ASI_CRM_SG_Value__c){
                            prosSegVolumeStatus.add(pIL.ASI_CRM_SG_Pros_Segmentation__c);
                        }
                    }
                }
            }
            system.debug('***prosSegVolumeStatus: ' + prosSegVolumeStatus);
            for(ASI_CRM_Pros_Segmentation__c prosSeg: [SELECT Id, ASI_CRM_SG_Group_Outlet_Type__c,
                                    ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Image_Criteria_Set__c,
                                    ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Volume_Criteria_Set__c,
                                    ASI_CRM_SG_Is_Image_Level_Modified__c, ASI_CRM_SG_Is_Volume_Potential_Modified__c
                                    FROM ASI_CRM_Pros_Segmentation__c
                                    WHERE ASI_CRM_SG_Group_Outlet_Type__c IN:groupOutletNameSet
                                    LIMIT 49999]){
                                    
                if(prosSegImageStatus.size() > 0){
                    prosSeg.ASI_CRM_SG_Is_Image_Level_Modified__c = (prosSegImageStatus.contains(prosSeg.Id))?true:false;
                }
                if(prosSegVolumeStatus.size() > 0){
                    prosSeg.ASI_CRM_SG_Is_Volume_Potential_Modified__c = (prosSegVolumeStatus.contains(prosSeg.Id))?true:false;
                }
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
    
    public static ASI_CRM_ID_Card__c returnIdCard(Id accountId){
        ASI_CRM_ID_Card__c idCard = null;
        if (accountId!=null){
            List<ASI_CRM_ID_Card__c> idCards = [SELECT Id  , ASI_CRM_SG_Outlet__c
                                                FROM ASI_CRM_ID_Card__c  WHERE ASI_CRM_SG_Outlet__c=:accountId]; 
            
            if (idCards.size()>0)
                idCard = idCards[0];
            //TODO Create new ID Card - FOR VERIFICATION
        }
        return idCard;
    }
    
    public static Map<Id, ASI_CRM_ID_Card__c> returnIdCardMap(Set<Id> accountIdSet){
        Map<Id, ASI_CRM_ID_Card__c> idCardMap = New Map<Id, ASI_CRM_ID_Card__c>();
        List<ASI_CRM_ID_Card__c> idCards = new List<ASI_CRM_ID_Card__c>();
        
        if (accountIdSet!=null){
            idCards = [SELECT Id  , ASI_CRM_SG_Outlet__c 
                        FROM ASI_CRM_ID_Card__c WHERE ASI_CRM_SG_Outlet__c IN:accountIdSet];  
            
            for(ASI_CRM_ID_Card__c idCard : idCards){
               idCardMap.put(idCard.ASI_CRM_SG_Outlet__c, idCard);
            }
            //TODO Create new ID Card - FOR VERIFICATION
        }
        return idCardMap;
    }
    
    public static void assignVolumePotential(List<ASI_CRM_Pros_Segmentation__c> prosSegmentationsRef, Map<Id, ASI_CRM_ID_Card__c> idCards){
        String currentGroupOutletType = '';
        System.Savepoint pSavepoint = Database.setSavepoint();
            
        Set<Id> prosSegmentationId = new Set<Id>();
        List<ASI_CRM_Pros_Segmentation__c> updateProsSegmentations = new List<ASI_CRM_Pros_Segmentation__c>();
        List<ASI_CRM_Pros_Volume_Potential__c> newProsVolumePotential = new List<ASI_CRM_Pros_Volume_Potential__c>();
        List<ASI_CRM_Pros_Segmentation__c> prosSegmentations = new List<ASI_CRM_Pros_Segmentation__c>();
        Map<Id,  List<ASI_CRM_Volume_Potential_Threshold__c>> volumePotentialsMap = new Map<Id,  List<ASI_CRM_Volume_Potential_Threshold__c>>();
        
        try{
            if (idCards.size()>0 && prosSegmentationsRef.size()>0){
                //Get Volume Index Total
                System.debug('Flag - AssignVolPotential - ID Card Map:' + idCards);
                Set<Id> prosSegId = new Set<Id>();
                Set<Id> groupOutletSet = new Set<Id>();
                Map<Id, Double> volIndexTotalMap = retrieveIDCardVolumeIndexMap(idCards);
                ASI_CRM_Criteria_Threshold__c volPotentialCriteria = retrieveVolumePotentialCriteria();               
                
                //Get all Group Outlet Type
                for(ASI_CRM_Pros_Segmentation__c prosSegmentation : prosSegmentationsRef){
                    if (prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c != null)
                    {
                        prosSegId.add(prosSegmentation.Id);
                        groupOutletSet.add(prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c);
                    }
                }
                //Get Pros Segmentation Details
                prosSegmentations = [SELECT Id, ASI_CRM_SG_Account__c, ASI_CRM_SG_Customer__c,
                                    ASI_CRM_SG_Group_Outlet_Type__c, ASI_CRM_SG_Image_Level_Threshold__c, ASI_CRM_SG_Is_Image_Level_Modified__c,
                                    ASI_CRM_SG_Is_Volume_Potential_Modified__c, ASI_CRM_SG_Outlet_Type__c, ASI_CRM_SG_Service_Pack__c, ASI_CRM_SG_Total_Image_Level_Weight__c,
                                    ASI_CRM_SG_Total_Volume_Weight__c, ASI_CRM_SG_Volume_Potential_Threshold__c FROM ASI_CRM_Pros_Segmentation__c
                                    WHERE Id IN:prosSegId LIMIT 49999];
                // Get Volume Potential Threshold
                if(groupOutletSet.size()>0){
                    for(ASI_CRM_Volume_Potential_Threshold__c volumePotential: [SELECT ASI_CRM_SG_Min_Weight__c, ASI_CRM_SG_Group_Outlet_Type__c 
                                    FROM ASI_CRM_Volume_Potential_Threshold__c
                                    WHERE ASI_CRM_SG_Group_Outlet_Type__c IN:groupOutletSet
                                    ORDER BY ASI_CRM_SG_Min_Weight__c LIMIT 49999]){
                        List<ASI_CRM_Volume_Potential_Threshold__c> volThresholdList = (volumePotentialsMap.containsKey(volumePotential.ASI_CRM_SG_Group_Outlet_Type__c))?volumePotentialsMap.get(volumePotential.ASI_CRM_SG_Group_Outlet_Type__c):new List<ASI_CRM_Volume_Potential_Threshold__c>();
                        volThresholdList.add(volumePotential);
                        volumePotentialsMap.put(volumePotential.ASI_CRM_SG_Group_Outlet_Type__c, volThresholdList);
                    }
                }
                
                for (ASI_CRM_Pros_Segmentation__c prosSegmentation : prosSegmentations)
                {
                    System.debug('Flag - AssignVolPotential - Volume Potential Criteria: '+ volPotentialCriteria + '-');
                    if ((volPotentialCriteria!=null) && (idCards.containsKey(prosSegmentation.ASI_CRM_SG_Customer__c))){
                        System.debug('Flag - AssignVolPotential - Calculating totalAnnualWeight');
                        //Get ID Card Info
                        ASI_CRM_ID_Card__c idCard = idCards.get(prosSegmentation.ASI_CRM_SG_Customer__c);
                        Double totalAnnualVol = (volIndexTotalMap.get(idCard.Id)!=null)?volIndexTotalMap.get(idCard.Id):0;//idCard.ASI_CRM_SG_Total_Annual_Volume__c;
                        Decimal totalAnnualWeight = Decimal.valueOf(totalAnnualVol) * (volPotentialCriteria.ASI_CRM_SG_Weight__c/100);///100;
                        
                        //Process Pros Segmentation
                        System.debug('Flag - AssignVolPotential - totals:' + idCard +'--'+totalAnnualVol+'--'+totalAnnualWeight);
                        System.debug('Flag - AssignVolPotential - Group Outlet:' + prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c);
                        if (prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c != null)
                        {
                            List<ASI_CRM_Volume_Potential_Threshold__c> volumePotentials = (volumePotentialsMap.containsKey(prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c))?volumePotentialsMap.get(prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c):new List<ASI_CRM_Volume_Potential_Threshold__c>();
                            //Set Pros Segmentation 
                            System.debug('Flag - AssignVolPotential - Retrieve VP: ' + totalAnnualWeight + '|' +currentGroupOutletType+'-'+ volumePotentials);
                            prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c = (volumePotentials.size()>0)?retrieveVolumePotential (totalAnnualWeight, volumePotentials):null;
                            updateProsSegmentations.add(prosSegmentation);
                        }
                        //Add Pros Segmentation for list of old Pros Volume Potential
                        prosSegmentationId.add(prosSegmentation.Id);
                        //Create New Pros Volume Potential
                        Id recordtypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Pros_Volume_Potential__cASI_CRM_TH_Pros_Volume_Potential');
                        ASI_CRM_Pros_Volume_Potential__c prosVolPotential = new ASI_CRM_Pros_Volume_Potential__c();
                        prosVolPotential.recordTypeId = recordtypeId; //Added by Twinkle @20150622
                        prosVolPotential.ASI_CRM_SG_Criteria_Threshold__c = volPotentialCriteria.Id;
                        prosVolPotential.ASI_CRM_SG_Answer__c = String.valueOf(Integer.valueOf(totalAnnualVol));
                        prosVolPotential.ASI_CRM_SG_Weight__c = totalAnnualWeight;
                        prosVolPotential.ASI_CRM_SG_Pros_Segmentation__c = prosSegmentation.Id;
                        newProsVolumePotential.add(prosVolPotential);
                    }
                }
                
                //Delete Old Pros Volume Potential
                ASI_CRM_Pros_Volume_Potential__c[] oldVolumePotentialCriteria = [SELECT Id FROM ASI_CRM_Pros_Volume_Potential__c
                                     WHERE ASI_CRM_SG_Pros_Segmentation__r.Id IN: prosSegmentationId]; 
                if (oldVolumePotentialCriteria.size()>0)
                    Database.delete(oldVolumePotentialCriteria);
                    
                //Insert new Pros Volume Potential
                if (newProsVolumePotential.size()>0)
                    system.debug('**Pros Volu' + newProsVolumePotential);
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
    
    public static void assignImageLevel(Map<Id, ASI_CRM_Pros_Segmentation__c> prosSegmentations, Map<Id, ASI_CRM_ID_Card__c> idCards)
    {
        String currentImageLevel = '';
        System.Savepoint pSavepoint = Database.setSavepoint();
        
        List<ASI_CRM_Pros_Segmentation__c> updatedProsSegmentation = new List<ASI_CRM_Pros_Segmentation__c>();
        List<ASI_CRM_Pros_Image_Level__c> updatedProsImageLevel = new List<ASI_CRM_Pros_Image_Level__c>();
        
        try{
            if(prosSegmentations.size()>0 && idCards.size()>0)
            {
                ASI_CRM_TH_CriteriaManager mgr = new ASI_CRM_TH_CriteriaManager();
                
                Map<Id, List<ASI_CRM_Pros_Image_Level__c>> prosImageLevelMap = retrieveProsImageLevel(prosSegmentations.keySet());
                System.debug('Flag - Image Level prosImageLevelMap:' + prosImageLevelMap);  
                        
                for(Id key: prosSegmentations.keySet()){
                    ASI_CRM_Pros_Segmentation__c prosSeg = prosSegmentations.get(key);
                    
                    if(prosSeg.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Image_Criteria_Set__c != null){
                        ASI_CRM_Criteria_Threshold__c imageLevelCriteria = retrieveImageLevelCriteria(prosSeg.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Image_Criteria_Set__c);
                        System.debug('Flag - Image Level Criteria Thresholds:' + imageLevelCriteria);
                    
                        Map<Id, List<ASI_CRM_Criteria_Answer__c>> imageLevelCriteriaAnswers = retrieveCriteriaAnswers(imageLevelCriteria);
                        
                        List<ASI_CRM_Pros_Image_Level__c> prosImageLevel = prosImageLevelMap.get(key);
                        ASI_CRM_Pros_Image_Level__c selectedProsImage = findCriteriaThresholdInPros (imageLevelCriteria.Id, prosImageLevel);
                        
                        if((selectedProsImage!=null) && (idCards.containsKey(prosSeg.ASI_CRM_SG_Customer__c)) && (imageLevelCriteriaAnswers.size()>0)){
                            //Get old weight
                            Double totalImageLevelWeight = prosSeg.ASI_CRM_SG_Total_Image_Level_Weight__c;
                            Double tempImageLevelWeight = totalImageLevelWeight - selectedProsImage.ASI_CRM_SG_Weight__c;
                            String answer = String.valueOf(idCards.get(prosSeg.ASI_CRM_SG_Customer__c).ASI_CRM_SG_Total_Super_Ultra_Brands__c);
                            
                            System.debug('Flag - Assignment Image Level - Answer:' + answer);
                            //Calculate new weight
                            Double answerWeight = mgr.newClassInstance(imageLevelCriteria.RecordTypeId).calculateCriteria(Double.valueOf(imageLevelCriteria.ASI_CRM_SG_Weight__c), 
                                                                            imageLevelCriteriaAnswers.get(imageLevelCriteria.Id), 
                                                                            answer);
                            
                            Double newTotalImageLevelWeight = tempImageLevelWeight + answerWeight;
                            Id imageLevel = retrieveImageLevel(newTotalImageLevelWeight, returnImageLevels(prosSeg.ASI_CRM_SG_Group_Outlet_Type__c));
                            
                            //Set New Values
                            selectedProsImage.ASI_CRM_SG_Weight__c = answerWeight;
                            selectedProsImage.ASI_CRM_SG_Answer__c = answer;
                            updatedProsImageLevel.add(selectedProsImage);
                            
                            if(imageLevel!=null){
                                prosSeg.ASI_CRM_SG_Image_Level_Threshold__c = imageLevel;
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
    
    public static Id retrieveImageLevel (Double score, List<ASI_CRM_Image_Level_Threshold__c> imageLevels){
        Id imageId = null;
        
        if(imageLevels.size()>0){
            if (score > imageLevels[imageLevels.size()-1].ASI_CRM_SG_Min_Weight__c){
                imageId = imageLevels[imageLevels.size()-1].Id;
            }else{
                for (Integer i=0; i<imageLevels.size(); i++){
                    Double left = imageLevels[i].ASI_CRM_SG_Min_Weight__c;
                    Double right = imageLevels[i].ASI_CRM_SG_Min_Weight__c;
                    if (imageLevels.size()-1 != i)
                        right = imageLevels[i+1].ASI_CRM_SG_Min_Weight__c;
                
                    if(left == score || score<right) 
                    {
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

    public static String retrieveVolumePotential (Decimal score, List<ASI_CRM_Volume_Potential_Threshold__c> volumePotentials){
        String volumeLevel = null;
        
        if(volumePotentials.size()>0){
            if (score > volumePotentials[volumePotentials.size()-1].ASI_CRM_SG_Min_Weight__c){
                volumeLevel = volumePotentials[volumePotentials.size()-1].Id;
            }else{
                for (Integer i=0; i<volumePotentials.size(); i++){
                    Double left = volumePotentials[i].ASI_CRM_SG_Min_Weight__c;
                    Double right = volumePotentials[i].ASI_CRM_SG_Min_Weight__c;
                    if (volumePotentials.size()-1 != i)
                        right = volumePotentials[i+1].ASI_CRM_SG_Min_Weight__c;
                
                    if(left == score || score<right) 
                    {
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
    
    public static ASI_CRM_Criteria_Threshold__c retrieveVolumePotentialCriteria(){
        ASI_CRM_Criteria_Threshold__c volPotentialCriteria = null;
        List<ASI_CRM_Criteria_Threshold__c> tempVolCriterias = [SELECT Id, ASI_CRM_SG_Criteria_Set__c, 
                                                            ASI_CRM_SG_Criteria_Type__c, ASI_CRM_SG_Question__c, 
                                                            ASI_CRM_SG_Weight__c 
                                                            FROM ASI_CRM_Criteria_Threshold__c
                                                            WHERE ASI_CRM_SG_Question__c=:VOLUME_POTENTIAL_STATEMENT
                                                            LIMIT 1];
        if (tempVolCriterias.size()>0)
            volPotentialCriteria = tempVolCriterias[0];
        
        return  volPotentialCriteria;                                               
    }
    
    public static Map<Id, Double> retrieveIDCardVolumeIndexMap(Map<Id, ASI_CRM_ID_Card__c> idCards){
        Map<Id, Double> idCardVolumeIndexMap = new Map<Id, Double>();
        
        Set<Id> idCardKeys = new Set<Id>();
        for(Id key: idCards.keySet()){
            idCardKeys.add(idCards.get(key).Id);
        }                                                   
        AggregateResult[] groupedResults = [SELECT ASI_CRM_SG_ID_Card__c, SUM(ASI_CRM_SG_Annual_Volume_Index_X__c) 
                                            FROM ASI_CRM_ID_Card_Volume__c 
                                            WHERE ASI_CRM_SG_ID_Card__c in:idCardKeys
                                            GROUP BY ASI_CRM_SG_ID_Card__c];
        
        System.debug('flag - ID Card Volume:' + groupedResults);
        
        for (AggregateResult ar : groupedResults)  {
            idCardVolumeIndexMap.put(String.valueOf(ar.get('ASI_CRM_SG_ID_Card__c')), Double.valueOf(ar.get('expr0')));
        }
        
        System.debug('FLAG - ID CARD VOL INDEX: ' + idCardVolumeIndexMap);
        return idCardVolumeIndexMap;
    }
    
        
    public static ASI_CRM_Criteria_Threshold__c retrieveImageLevelCriteria(Id criteriaSetId){
        ASI_CRM_Criteria_Threshold__c imageLevelCriteria = null;
        List<ASI_CRM_Criteria_Threshold__c> tempImageLevelCriteria = [SELECT Id, ASI_CRM_SG_Criteria_Set__c, 
                                                            ASI_CRM_SG_Criteria_Type__c, ASI_CRM_SG_Question__c, 
                                                            ASI_CRM_SG_Weight__c, RecordTypeId
                                                            FROM ASI_CRM_Criteria_Threshold__c
                                                            WHERE ASI_CRM_SG_Question__c=:IMAGE_LEVEL_STATEMENT
                                                            AND ASI_CRM_SG_Criteria_Set__c=:criteriaSetId
                                                            LIMIT 1];
        if (tempImageLevelCriteria.size()>0)
            imageLevelCriteria = tempImageLevelCriteria[0];
        
        return  imageLevelCriteria;                                             
    }
    
    public static Map<Id, ASI_CRM_Criteria_Threshold__c> retrieveImageLevelCriteria(List<Id> criteriaSetIds){
        Map<Id, ASI_CRM_Criteria_Threshold__c> imageLevelCriterias = new Map<Id, ASI_CRM_Criteria_Threshold__c>();
        
        List<ASI_CRM_Criteria_Threshold__c> tempImageLevelCriteria = [SELECT Id, ASI_CRM_SG_Criteria_Set__c, 
                                                            ASI_CRM_SG_Criteria_Type__c, ASI_CRM_SG_Question__c, 
                                                            ASI_CRM_SG_Weight__c, RecordTypeId
                                                            FROM ASI_CRM_Criteria_Threshold__c
                                                            WHERE ASI_CRM_SG_Question__c=:IMAGE_LEVEL_STATEMENT
                                                            AND ASI_CRM_SG_Criteria_Set__c IN:criteriaSetIds
                                                            LIMIT 1];
        for (ASI_CRM_Criteria_Threshold__c cTreshold: tempImageLevelCriteria){
            imageLevelCriterias.put(cTreshold.ASI_CRM_SG_Criteria_Set__c, cTreshold);
        }
        
        return  imageLevelCriterias;                                                
    }
    
    public static Map<Id, List<ASI_CRM_Criteria_Answer__c>> retrieveCriteriaAnswers(ASI_CRM_Criteria_Threshold__c criteriaThreshold){       
        Map<Id, List<ASI_CRM_Criteria_Answer__c>> criteriaAnswers = new Map<Id, List<ASI_CRM_Criteria_Answer__c>>();

        List<ASI_CRM_Criteria_Answer__c> answers = new List<ASI_CRM_Criteria_Answer__c>([SELECT Id, RecordTypeId,
                    ASI_CRM_SG_Value__c, 
                    ASI_CRM_SG_Base_Currency__c, ASI_CRM_SG_Base_Integer__c,
                    ASI_CRM_SG_Condition__c, ASI_CRM_SG_Criteria_Threshold__r.Id,
                    ASI_CRM_SG_Label__c, ASI_CRM_SG_Weight__c
                    FROM ASI_CRM_Criteria_Answer__c 
                    WHERE ASI_CRM_SG_Criteria_Threshold__r.Id =: criteriaThreshold.Id]);

        System.debug('getAnswers:'+answers);
        
        
        if (answers.size()>0){
            for (ASI_CRM_Criteria_Answer__c ans: answers){
                List<ASI_CRM_Criteria_Answer__c> criteriaAnsList = new List<ASI_CRM_Criteria_Answer__c>();
                if (criteriaAnswers.containsKey(ans.ASI_CRM_SG_Criteria_Threshold__r.Id)){
                    criteriaAnsList = criteriaAnswers.get(ans.ASI_CRM_SG_Criteria_Threshold__r.Id);
                }
                criteriaAnsList.add(ans);
                criteriaAnswers.put(ans.ASI_CRM_SG_Criteria_Threshold__r.Id, criteriaAnsList);
            }
        }
        System.debug('getCriteriaAnswers:'+criteriaAnswers);
        return criteriaAnswers;
    }
    
    public static Map<Id, List<ASI_CRM_Pros_Image_Level__c>> retrieveProsImageLevel(Set<Id> prosSegIdList){
        Map<Id, List<ASI_CRM_Pros_Image_Level__c>> imageLevelMap = new Map<Id, List<ASI_CRM_Pros_Image_Level__c>>();
        
        List<ASI_CRM_Pros_Image_Level__c> prosImageLevels = new List<ASI_CRM_Pros_Image_Level__c>([SELECT Id, ASI_CRM_SG_Criteria_Threshold__c, 
                            ASI_CRM_SG_Weight__c, ASI_CRM_SG_Answer__c, ASI_CRM_SG_Pros_Segmentation__c
                            FROM ASI_CRM_Pros_Image_Level__c
                            WHERE ASI_CRM_SG_Pros_Segmentation__c in: prosSegIdList]);
                            
        for(ASI_CRM_Pros_Image_Level__c prosImageLevel: prosImageLevels)
        {
            List<ASI_CRM_Pros_Image_Level__c> prosImageList = new List<ASI_CRM_Pros_Image_Level__c>();
            if (imageLevelMap.containsKey(prosImageLevel.ASI_CRM_SG_Pros_Segmentation__c)){
                prosImageList = imageLevelMap.get(prosImageLevel.ASI_CRM_SG_Pros_Segmentation__c);
            }
            prosImageList.add(prosImageLevel);
            imageLevelMap.put(prosImageLevel.ASI_CRM_SG_Pros_Segmentation__c, prosImageList);
        }
        
        return imageLevelMap;             
    }
    
    public static ASI_CRM_Pros_Image_Level__c findCriteriaThresholdInPros (Id criteriaThresholdId, List<ASI_CRM_Pros_Image_Level__c> prosList){
        ASI_CRM_Pros_Image_Level__c foundPros = null;
        if(prosList!=null){
            for(ASI_CRM_Pros_Image_Level__c pros: prosList){
                if (pros.ASI_CRM_SG_Criteria_Threshold__c==criteriaThresholdId){
                    foundPros = pros;
                    break;
                }
            }
        }
        
        return foundPros;
    }
    
    public static Map<Id, ASI_CRM_Group_Outlet_Type__c> retrieveGroupOutletTypes(List<ASI_CRM_Pros_Segmentation__c> prosSegmentationList){
         Map<Id, ASI_CRM_Group_Outlet_Type__c> prosGroupOutletMap = new Map<Id, ASI_CRM_Group_Outlet_Type__c>(); //Id= ProsSegmentation Id
         
         List<String> groupOutletNameList = new List<String>();
         Map<String, ASI_CRM_Pros_Segmentation__c> prosAffiliateGroupMap= new Map<String, ASI_CRM_Pros_Segmentation__c>();
         
         for(ASI_CRM_Pros_Segmentation__c pros: prosSegmentationList){
            groupOutletNameList.add(pros.ASI_CRM_SG_Group_Outlet_Type__c);
            prosAffiliateGroupMap.put(String.valueOf(pros.ASI_CRM_SG_Group_Outlet_Type__c), pros);//Baltics LT/LV
         }
         
         System.debug('Flag - Retrieve Group Outlet Type:' + prosAffiliateGroupMap);
         
         List<ASI_CRM_Group_Outlet_Type__c> groupOutletTypes = new List<ASI_CRM_Group_Outlet_Type__c>(
                                    [SELECT Id, ASI_CRM_SG_Group_Outlet_Name__c, 
                                    ASI_CRM_SG_Image_Criteria_Set__c, 
                                    ASI_CRM_SG_Volume_Criteria_Set__c
                                    FROM ASI_CRM_Group_Outlet_Type__c
                                    WHERE ASI_CRM_SG_Name__c in:groupOutletNameList]);
        
        for(ASI_CRM_Group_Outlet_Type__c grp:groupOutletTypes){
            String key = grp.Id;
            if(prosAffiliateGroupMap.containsKey(key)){
                prosGroupOutletMap.put(prosAffiliateGroupMap.get(key).Id, grp);
            }
        }
        
        return prosGroupOutletMap;
    }
    
    public static List<String> returnMarketShareLabels(){
        List<String> msLabels = new List<String>();
        Schema.DescribeFieldResult fieldResult = ASI_CRM_DAMD_Threshold__c.ASI_CRM_SG_Market_Share__c.getDescribe();
        System.debug('Describe Field: ' + fieldResult);
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry ms: values){
                msLabels.add(ms.getValue());
        }
        return msLabels;
    }
    
    public static Map<String, String> retrieveDAMDMatrix(ASI_CRM_ID_Card__c IdCard, ASI_CRM_Pros_Segmentation__c prosSegmentation){
              
        List<String> volLabels = returnVolumePotentialLabels();
        List<String> msLabels = returnMarketShareLabels();
        Map<String, String> damdmatrixMap = new Map<String, String>();
        Decimal allNonPRSAnnualVol = 0;
        Decimal allPRSAnnualVol = 0;
        Decimal mshare = 0;
                                            
        //Compute Annual Vol and Annual Vol of PR Brands                                    
        for(ASI_CRM_ID_Card_Volume__c idCardVol : [SELECT Id, ASI_CRM_SG_ID_Card__c, Name, 
                                                       ASI_CRM_SG_Annual_Volume__c, ASI_CRM_SG_Dose_Service__c, 
                                                       ASI_CRM_SG_Service_Mark__c, ASI_CRM_SG_No_Premium_Brands__c,
                                                       ASI_CRM_SG_No_SuperPremium_Brands__c, ASI_CRM_SG_No_UltraPremium_Brands__c,
                                                       ASI_CRM_SG_Service_Mark__r.ASI_CRM_SG_Quality_Is_Competitor__c,
                                                       ASI_CRM_SG_Service_Mark__r.Name
                                                       FROM ASI_CRM_ID_Card_Volume__c 
                                                       WHERE ASI_CRM_SG_ID_Card__c =: IdCard.Id]){
            
            if(idCardVol.ASI_CRM_SG_Annual_Volume__c != null){
                if(idCardVol.ASI_CRM_SG_Service_Mark__r.ASI_CRM_SG_Quality_Is_Competitor__c){
                    allNonPRSAnnualVol = allNonPRSAnnualVol + idCardVol.ASI_CRM_SG_Annual_Volume__c;
                }
                else{
                    allPRSAnnualVol = allPRSAnnualVol + idCardVol.ASI_CRM_SG_Annual_Volume__c;
                }
            }
        }
        
        if(allPRSAnnualVol > 0 && allNonPRSAnnualVol > 0){
            mshare = (allPRSAnnualVol/allNonPRSAnnualVol).setscale(2);
        }
        
        Decimal prs = allNonPRSAnnualVol + allPRSAnnualVol; //IdCard.ASI_CRM_SG_Total_Annual_Volume__c
        String outletType = IdCard.ASI_CRM_SG_Outlet__r.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c;
        
        system.debug('Market SHARE ##: '+ mshare);
        system.debug('Annual NON PRS Volume ' + allNonPRSAnnualVol + ' Annual PRS Volume ' + allPRSAnnualVol);     
        system.debug('TEEEST '+ IdCard.ASI_CRM_SG_Outlet__r.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c);
        
        List<ASI_CRM_DAMD_Threshold__c> damdList = [SELECT Id, ASI_CRM_SG_Min_Weight__c, ASI_CRM_SG_Action__c, ASI_CRM_SG_Market_Share__c, ASI_CRM_SG_Volume_Potential__c, ASI_CRM_SG_Volume_Potential_Name__c FROM ASI_CRM_DAMD_Threshold__c WHERE ASI_CRM_SG_Group_Outlet_Type__c =: IdCard.ASI_CRM_SG_Outlet__r.ASI_CRM_SG_Group_Outlet_Type__c ORDER BY ASI_CRM_SG_Min_Weight__c DESC];
        Id  vpId = null;
        Id damdId = null;
        list<ASI_CRM_Volume_Potential_Threshold__c> lvpt = [SELECT ASI_CRM_SG_Volume_Potential__r.Id FROM ASI_CRM_Volume_Potential_Threshold__c WHERE Id =: prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c];
        if (lvpt != null && lvpt.size() > 0) 
            vpid = lvpt[0].ASI_CRM_SG_Volume_Potential__r.Id;
        
        for(ASI_CRM_DAMD_Threshold__c damd : damdList){
            damdmatrixMap.put(damd.ASI_CRM_SG_Market_Share__c+damd.ASI_CRM_SG_Volume_Potential_Name__c, '--');
        }
        
        for(ASI_CRM_DAMD_Threshold__c damd : damdList){
            system.debug('mini' + mshare + ' > '+ damd.ASI_CRM_SG_Min_Weight__c);
            if(mshare >= damd.ASI_CRM_SG_Min_Weight__c && vpId == damd.ASI_CRM_SG_Volume_Potential__c){        
                damdmatrixMap.put(damd.ASI_CRM_SG_Market_Share__c+damd.ASI_CRM_SG_Volume_Potential_Name__c, damd.ASI_CRM_SG_Action__c);
                damdId = damd.Id;
                break;
            }      
        }
        
        if(prosSegmentation.ASI_CRM_SG_DAMD_Threshold__c == null || prosSegmentation.ASI_CRM_SG_DAMD_Threshold__c != damdId){
            prosSegmentation.ASI_CRM_SG_DAMD_Threshold__c = damdId;
            
            update prosSegmentation;
        }
        
        return damdmatrixMap;
    }
    
}