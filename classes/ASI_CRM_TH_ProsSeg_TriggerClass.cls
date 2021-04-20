/*********************************************************************************
 * Name: ASI_CRM_TH_ProsSeg_TriggerClass
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/03/2016       Introv: Twinkle li      Cloned from ASI_CRM_TW_ProsSeg_TriggerClass
*********************************************************************************/

public without sharing class ASI_CRM_TH_ProsSeg_TriggerClass{

    public static void routineAfterAll1(List<ASI_CRM_Pros_Segmentation__c> triggerNew , Map<Id, ASI_CRM_Pros_Segmentation__c> triggerOld){
    System.debug('ASI_CRM_SG_ProsSegmentationTrigger - AFTER UPDATE');
        Map<Id,ASI_CRM_Pros_Segmentation__c> prosSegServicePackUpdate = new Map<Id,ASI_CRM_Pros_Segmentation__c>();
        Map<Id,String> prosSegGroupOutlet = new Map<Id,String>();
        Map<Id,String> prosSegImageLevel = new Map<Id,String>();
        List<ASI_CRM_Pros_Segmentation__c> updatedProsSeg = new List<ASI_CRM_Pros_Segmentation__c>();
        
        Map<Id,ASI_CRM_Pros_Segmentation__c> prosSegGroupOutletUpdate = new Map<Id,ASI_CRM_Pros_Segmentation__c>();
        Set<Id> accountIdSet = new Set<Id>();
        List<Id> prosSegGroupOutletUpdateAfter = new List<Id>();
        List<ASI_CRM_Pros_Image_Level__c> updatedImageLevels = new List<ASI_CRM_Pros_Image_Level__c>();
        List<ASI_CRM_Pros_Volume_Potential__c> updatedVolumePotentials = new List<ASI_CRM_Pros_Volume_Potential__c>();
            
        for(ASI_CRM_Pros_Segmentation__c prosSeg: triggerNew){
            
            ASI_CRM_Pros_Segmentation__c newProsSeg = new ASI_CRM_Pros_Segmentation__c(Id=prosSeg.Id, 
                                                RecordTypeId=prosSeg.RecordTypeId,
                                                ASI_CRM_SG_Group_Outlet_Type__c=prosSeg.ASI_CRM_SG_Group_Outlet_Type__c, 
                                                ASI_CRM_SG_Image_Level__c=prosSeg.ASI_CRM_SG_Image_Level__c,
                                                ASI_CRM_SG_Volume_Potential__c=prosSeg.ASI_CRM_SG_Volume_Potential__c,
                                                ASI_CRM_SG_Outlet_Type__c=prosSeg.ASI_CRM_SG_Outlet_Type__c,
                                                ASI_CRM_SG_Service_Pack__c=prosSeg.ASI_CRM_SG_Service_Pack__c,
                                                ASI_CRM_SG_Is_Image_Level_Modified__c=prosSeg.ASI_CRM_SG_Is_Image_Level_Modified__c,
                                                ASI_CRM_SG_Is_Volume_Potential_Modified__c=prosSeg.ASI_CRM_SG_Is_Volume_Potential_Modified__c,
                                                ASI_CRM_SG_Customer__c=prosSeg.ASI_CRM_SG_Customer__c);
    
            //Process Before Update of Group Outlet Type - Reset service pack, image level and volume potential
            //Process After Update of Group Outlet Type - Reset service pack, image level and volume potential
            if ((Trigger.isUpdate && prosSeg.ASI_CRM_SG_Group_Outlet_Type__c != triggerOld.get(prosSeg.Id).ASI_CRM_SG_Group_Outlet_Type__c) || Trigger.isInsert)
            {   system.debug('++ flag 1');
                newProsSeg.ASI_CRM_SG_Service_Pack__c = null;
                newProsSeg.ASI_CRM_SG_Image_Level__c = null;
                newProsSeg.ASI_CRM_SG_Volume_Potential__c = null;
                newProsSeg.ASI_CRM_SG_Image_Level_Threshold__c=null;
                newProsSeg.ASI_CRM_SG_Volume_Potential_Threshold__c=null;
                newProsSeg.ASI_CRM_SG_Is_Image_Level_Modified__c = false;
                newProsSeg.ASI_CRM_SG_Is_Volume_Potential_Modified__c=false;
                prosSegGroupOutletUpdate.put(newProsSeg.Id,newProsSeg);
            }
            //Process Before Update of Image Level - Assign new Service Pack
            else if((Trigger.isUpdate && (prosSeg.ASI_CRM_SG_Image_Level__c != triggerOld.get(prosSeg.Id).ASI_CRM_SG_Image_Level__c) && (prosSeg.ASI_CRM_SG_Group_Outlet_Type__c == (triggerOld.get(prosSeg.Id).ASI_CRM_SG_Group_Outlet_Type__c))) || Trigger.isInsert)
            {   system.debug('++ flag 2');
                prosSegServicePackUpdate.put(newProsSeg.Id, newProsSeg);
                prosSegGroupOutlet.put(newProsSeg.Id, newProsSeg.ASI_CRM_SG_Group_Outlet_Type__c);
                prosSegImageLevel.put(newProsSeg.Id, newProsSeg.ASI_CRM_SG_Image_Level__c);
            }
            else{
                continue;
            }
        }
        
        System.debug('Image Level Update Before: ' + prosSegServicePackUpdate);
        System.debug('Group Outlet Update Before: ' + prosSegGroupOutletUpdate);
        System.debug('Group Outlet Update After: ' + prosSegGroupOutletUpdateAfter);
        
        //Process Update of Image Level - Assign new Service Pack
        if(prosSegServicePackUpdate.size()>0){
            System.Savepoint pSavepoint = Database.setSavepoint();
            Map<String, ASI_CRM_ServicePack__c> spMap = new Map<String, ASI_CRM_ServicePack__c>();
            List<ASI_CRM_ServicePack__c> servicePacks =  [SELECT Id, 
                                                                ASI_CRM_SG_Outlet_Type__c,
                                                                ASI_CRM_SG_Segmentation__c
                                                                FROM ASI_CRM_ServicePack__c
                                                                WHERE ASI_CRM_SG_Outlet_Type__c IN:prosSegGroupOutlet.values()
                                                                AND ASI_CRM_SG_Segmentation__c IN:prosSegImageLevel.values()
                                                                ];
                                                                
            System.debug('Flag - ServicePacks: ' + servicePacks);
            
            String test = '[SELECT Id, ASI_CRM_SG_Affiliate__c, '+
            'ASI_CRM_SG_Outlet_Type__c, ASI_CRM_SG_Segmentation__c FROM ASI_CRM_SG_ServicePack__c '+
            'WHERE ASI_CRM_SG_Outlet_Type__c IN:'+prosSegGroupOutlet.values()+
            'AND ASI_CRM_SG_Segmentation__c IN:'+prosSegImageLevel.values()+'];';
            System.debug('TEST QUERY: ' + test);
            
            if (servicePacks.size()>0){
                for(ASI_CRM_ServicePack__c sp: servicePacks){
                    spMap.put(sp.ASI_CRM_SG_Outlet_Type__c+sp.ASI_CRM_SG_Segmentation__c, sp);
                }
            }
            
            System.debug('Flag - ServicePack Map:' + spMap);
            for(Id prosSegKey: prosSegServicePackUpdate.keySet()){
                ASI_CRM_Pros_Segmentation__c ps = prosSegServicePackUpdate.get(prosSegKey);
                String tempSpKey = String.valueOf(ps.ASI_CRM_SG_Group_Outlet_Type__c) + String.valueOf(ps.ASI_CRM_SG_Image_Level__c);
                System.debug('Flag - is Service pack found: ' + spMap.containsKey(tempSpKey) + '|' + tempSpKey);
                if(spMap.containsKey(tempSpKey)){
                    ps.ASI_CRM_SG_Service_Pack__c = spMap.get(tempSpKey).Id;
                }else{
                    ps.ASI_CRM_SG_Service_Pack__c = null;
                }
                updatedProsSeg.add(ps);
            }
            
            try{
                Database.SaveResult[] updateResults;
                System.debug('Flag - Update Pros Seg: ' + updatedProsSeg);
                if(updatedProsSeg.size()>0){
                    updateResults = Database.update(updatedProsSeg);
                    System.debug('Flag - Image Update Result: ' + updateResults);
                }
                
            }
            catch(Exception e){
                System.debug('ASI_CRM_SG_ProsSegmentationTrigger Update Error: ' + e);
                Database.rollback(pSavepoint);                
            }
        }
        
        //Reset Group Outlet Type dependent objects
        if(prosSegGroupOutletUpdate.size()>0){
            System.Savepoint pSavepoint = Database.setSavepoint();
            try{
                Database.SaveResult[] updateResults;
                Database.Deleteresult[] deleteImageLevelResults;
                Database.Deleteresult[] deleteVolumePotentialResults;
                
                List<ASI_CRM_Pros_Image_Level__c> tempImageLevels = [SELECT Id 
                                                            from ASI_CRM_Pros_Image_Level__c 
                                                            WHERE ASI_CRM_SG_Pros_Segmentation__c IN:prosSegGroupOutletUpdate.keySet()];
                //get Prod Volume Potential
                List<ASI_CRM_Pros_Volume_Potential__c> tempVolumePotentials = [SELECT Id 
                                                                from ASI_CRM_Pros_Volume_Potential__c 
                                                                WHERE ASI_CRM_SG_Pros_Segmentation__c IN:prosSegGroupOutletUpdate.keySet()];
    
                if(tempImageLevels.size()>0){
                    deleteImageLevelResults = Database.delete(tempImageLevels);
                }
                System.debug('ASI_CRM_SG_ProsSegmentationTrigger DELETE IMGAE RESULT: ' + deleteImageLevelResults);
                if(tempVolumePotentials.size()>0){
                    deleteVolumePotentialResults = Database.delete(tempVolumePotentials);
                }
                System.debug('ASI_CRM_SG_ProsSegmentationTrigger DELETE VOLUME RESULT: ' + deleteVolumePotentialResults);
                if(prosSegGroupOutletUpdate.size()>0){
                    updateResults = Database.update(prosSegGroupOutletUpdate.values());
                }
                System.debug('ASI_CRM_SG_ProsSegmentationTrigger UPDATE RESULT: ' + updateResults);
            }
            catch(Exception e){
                System.debug('ASI_CRM_ProsSegmentationTrigger Update Error: ' + e);
                Database.rollback(pSavepoint);                  
            }
        }
    }
    //Added to set/reset Pros fields in EU Account Object
    public static void routineAfterAll2(List<ASI_CRM_Pros_Segmentation__c> triggerNew , Map<Id, ASI_CRM_Pros_Segmentation__c> triggerOld){
       Set<Id> asAccountIdSet = new Set<Id>();
       Set<Id> standardAccountIdSet = new Set<Id>();
       Set<Id> prosIdSet = new Set<Id>();
        
        for (ASI_CRM_Pros_Segmentation__c pros:  triggerNew){
            asAccountIdSet.add(pros.ASI_CRM_SG_Customer__c);  
            
        }
        Map<Id,ASI_CRM_AccountsAdditionalField__c> asAccountMap = new Map<Id,ASI_CRM_AccountsAdditionalField__c>([select id from ASI_CRM_AccountsAdditionalField__c where id in: asAccountIdSet]);
        system.debug('@@asAccountIdSet' + asAccountIdSet);
        system.debug('@@standardAccountIdSet' + standardAccountIdSet);
        Map<Id,ASI_CRM_AccountsAdditionalField__c> toUpdateASAccountList = new Map<Id,ASI_CRM_AccountsAdditionalField__c>();
        
        Map<Id, String> getMainSector = new Map<Id, String>();
        /*for(ASI_CRM_Pros_Segmentation__c p : [SELECT Id, ASI_CRM_SG_Outlet_Type__r.ASI_CRM_SG_Main_Sector__c FROM ASI_CRM_Pros_Segmentation__c WHERE Id in: triggerOld.keySet()]){
            getMainSector.put(p.Id, p.ASI_CRM_SG_Outlet_Type__r.ASI_CRM_SG_Main_Sector__c);
        }*/
        
        Map<Id,Account> toUpdateStandardAccountList = new Map<Id,Account>();
        
            for (ASI_CRM_Pros_Segmentation__c pros: triggerNew){  
                    
                ASI_CRM_AccountsAdditionalField__c acc = new ASI_CRM_AccountsAdditionalField__c(); 
                system.debug('@@Prosvalue::' + pros.ASI_CRM_SG_Group_Outlet_Type__c);
                acc.Id = pros.ASI_CRM_SG_Customer__c;
                if (pros.ASI_CRM_SG_Group_Outlet_Type__c != null){
                    acc.ASI_CRM_SG_Group_Outlet_Type__c = pros.ASI_CRM_SG_Group_Outlet_Type__c;
                }else{
                    acc.ASI_CRM_SG_Group_Outlet_Type__c = null;
                }
                
                if (pros.ASI_CRM_SG_Outlet_Type__c != null){
                    acc.ASI_CRM_SG_Outlet_Type__c = pros.ASI_CRM_SG_Outlet_Type__c;
                    //acc.ASI_CRM_SG_Main_Sector__c = getMainSector.get(pros.Id);
                }else{
                    acc.ASI_CRM_SG_Outlet_Type__c = null;
                    //acc.ASI_CRM_SG_Main_Sector__c = null;
                }
                if (pros.ASI_CRM_SG_Image_Level_Id__c != null && asAccountMap.get(acc.Id) != null){
                    acc.ASI_CRM_SG_Image_Level__c = pros.ASI_CRM_SG_Image_Level_Id__c;
                }
                
                if (pros.ASI_CRM_SG_Volume_Potential_Id__c != null){
                    acc.ASI_CRM_SG_Volume_Potential__c = pros.ASI_CRM_SG_Volume_Potential_Id__c;
                }else{
                    acc.ASI_CRM_SG_Volume_Potential__c = null;
                }
                toUpdateASAccountList.put(acc.id,acc); 
            }
            
            system.debug('toUpdateASAccountList' + toUpdateASAccountList);
 
        if (!Test.isRunningTest() && toUpdateASAccountList.size() > 0){
            update toUpdateASAccountList.values();
        }        
    }
}