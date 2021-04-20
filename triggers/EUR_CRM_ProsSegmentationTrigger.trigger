/**
HISTORY.

JAN 07.2015
    -modified the account update function to filter out the unaffected accounts(both eu and std).

*/
trigger EUR_CRM_ProsSegmentationTrigger on EUR_CRM_Pros_Segmentation__c (after update) {
    
    System.debug('EUR_CRM_ProsSegmentationTrigger - AFTER UPDATE');
    Map<Id,EUR_CRM_Pros_Segmentation__c> prosSegServicePackUpdate = new Map<Id,EUR_CRM_Pros_Segmentation__c>();
    Map<Id,String> prosSegGroupOutlet = new Map<Id,String>();
    Map<Id,String> prosSegImageLevel = new Map<Id,String>();
    Map<Id,String> prosSegAffiliate = new Map<Id,Id>();
    List<EUR_CRM_Pros_Segmentation__c> updatedProsSeg = new List<EUR_CRM_Pros_Segmentation__c>();
    
    Map<Id,EUR_CRM_Pros_Segmentation__c> prosToUpdateMap = new Map<Id,EUR_CRM_Pros_Segmentation__c>();
    Set<Id> accountIdSet = new Set<Id>();
    List<Id> prosSegGroupOutletUpdateAfter = new List<Id>();
    List<EUR_CRM_Pros_Image_Level__c> updatedImageLevels = new List<EUR_CRM_Pros_Image_Level__c>();
    List<EUR_CRM_Pros_Volume_Potential__c> updatedVolumePotentials = new List<EUR_CRM_Pros_Volume_Potential__c>();
        
    if (trigger.isAfter && trigger.isUpdate){
        for(EUR_CRM_Pros_Segmentation__c prosSeg: Trigger.new){
            
            EUR_CRM_Pros_Segmentation__c newProsSeg = new EUR_CRM_Pros_Segmentation__c(Id=prosSeg.Id, 
                                                RecordTypeId=prosSeg.RecordTypeId,
                                                EUR_CRM_Group_Outlet_Type__c=prosSeg.EUR_CRM_Group_Outlet_Type__c, 
                                                EUR_CRM_Image_Level__c=prosSeg.EUR_CRM_Image_Level__c,
                                                EUR_CRM_Affiliate__c=prosSeg.EUR_CRM_Affiliate__c,
                                                EUR_CRM_Volume_Potential__c=prosSeg.EUR_CRM_Volume_Potential__c,
                                                EUR_CRM_Outlet_Type__c=prosSeg.EUR_CRM_Outlet_Type__c,
                                                EUR_CRM_Service_Pack__c=prosSeg.EUR_CRM_Service_Pack__c,
                                                EUR_CRM_Is_Image_Level_Modified__c=prosSeg.EUR_CRM_Is_Image_Level_Modified__c,
                                                EUR_CRM_Is_Volume_Potential_Modified__c=prosSeg.EUR_CRM_Is_Volume_Potential_Modified__c,
                                                EUR_CRM_Standard_Account__c=prosSeg.EUR_CRM_Standard_Account__c);
            
            System.debug(prosSeg);
            System.debug(Trigger.oldMap.get(prosSeg.Id));
            
            //Process Before Update of Group Outlet Type - Reset service pack, image level and volume potential
            //Process After Update of Group Outlet Type - Reset service pack, image level and volume potential
            if ((prosSeg.EUR_CRM_Group_Outlet_Type__c != Trigger.oldMap.get(prosSeg.Id).EUR_CRM_Group_Outlet_Type__c) && 
                (prosSeg.EUR_CRM_Service_Pack__c                == Trigger.oldMap.get(prosSeg.Id).EUR_CRM_Service_Pack__c &&
                 prosSeg.EUR_CRM_Image_Level__c                 == Trigger.oldMap.get(prosSeg.Id).EUR_CRM_Image_Level__c &&
                 prosSeg.EUR_CRM_Volume_Potential__c            == Trigger.oldMap.get(prosSeg.Id).EUR_CRM_Volume_Potential__c &&
                 prosSeg.EUR_CRM_Image_Level_Threshold__c       == Trigger.oldMap.get(prosSeg.Id).EUR_CRM_Image_Level_Threshold__c &&
                 prosSeg.EUR_CRM_Volume_Potential_Threshold__c  == Trigger.oldMap.get(prosSeg.Id).EUR_CRM_Volume_Potential_Threshold__c
                )
               )
            {
               system.debug('++ flag 1');
                newProsSeg.EUR_CRM_Service_Pack__c = null;
                newProsSeg.EUR_CRM_Image_Level__c = null;
                newProsSeg.EUR_CRM_Volume_Potential__c = null;
                newProsSeg.EUR_CRM_Image_Level_Threshold__c=null;
                newProsSeg.EUR_CRM_Volume_Potential_Threshold__c=null;
                newProsSeg.EUR_CRM_Is_Image_Level_Modified__c = false;
                newProsSeg.EUR_CRM_Is_Volume_Potential_Modified__c=false;
                prosToUpdateMap.put(newProsSeg.Id, newProsSeg);
                accountIdSet.add(newProsSeg.EUR_CRM_Standard_Account__c);
            }
            //Process Before Update of Image Level - Assign new Service Pack
            else if((prosSeg.EUR_CRM_Image_Level__c != Trigger.oldMap.get(prosSeg.Id).EUR_CRM_Image_Level__c) && (prosSeg.EUR_CRM_Group_Outlet_Type__c == (Trigger.oldMap.get(prosSeg.Id).EUR_CRM_Group_Outlet_Type__c)))
            {
                system.debug('++ flag 2');
                prosSegServicePackUpdate.put(newProsSeg.Id, newProsSeg);
                prosSegGroupOutlet.put(newProsSeg.Id, newProsSeg.EUR_CRM_Group_Outlet_Type__c);
                prosSegImageLevel.put(newProsSeg.Id, newProsSeg.EUR_CRM_Image_Level__c);
                prosSegAffiliate.put(newProsSeg.Id, newProsSeg.EUR_CRM_Country_Code__c);//Baltics - reference to country code field
            }
            else{
                continue;
            }
        }
        
        System.debug('Image Level Update Before: ' + prosSegServicePackUpdate);
        System.debug('Group Outlet Update Before: ' + prosToUpdateMap);
        System.debug('Group Outlet Update After: ' + prosSegGroupOutletUpdateAfter);
        
        //Process Update of Image Level - Assign new Service Pack
        if(prosSegServicePackUpdate.size()>0){
            System.Savepoint pSavepoint = Database.setSavepoint();
            Map<String, EUR_CRM_Service_Pack__c> spMap = new Map<String, EUR_CRM_Service_Pack__c>();
            List<EUR_CRM_Service_Pack__c> servicePacks =  [SELECT Id, EUR_CRM_Affiliate__c, 
                                                                EUR_CRM_Outlet_Type__c,
                                                                EUR_CRM_Segmentation__c
                                                                FROM EUR_CRM_Service_Pack__c
                                                                WHERE EUR_CRM_Country_Code__c IN:prosSegAffiliate.values()
                                                                AND  EUR_CRM_Outlet_Type__c IN:prosSegGroupOutlet.values()
                                                                AND EUR_CRM_Segmentation__c IN:prosSegImageLevel.values()
                                                                ];
                                                                
            System.debug('Flag - ServicePacks: ' + servicePacks);
            
            String test = '[SELECT Id, EUR_CRM_Affiliate__c, '+
            'EUR_CRM_Outlet_Type__c, EUR_CRM_Segmentation__c FROM EUR_CRM_Service_Pack__c '+
            'WHERE EUR_CRM_Affiliate__c IN:'+prosSegAffiliate.values()+
            'AND  EUR_CRM_Outlet_Type__c IN:'+prosSegGroupOutlet.values()+
            'AND EUR_CRM_Segmentation__c IN:'+prosSegImageLevel.values()+'];';
            System.debug('TEST QUERY: ' + test);
            
            if (servicePacks.size()>0){
                for(EUR_CRM_Service_Pack__c sp: servicePacks){
                    //Key: Affiliate + GroupOutletType + ImageLevel
                    spMap.put(sp.EUR_CRM_Country_Code__c+sp.EUR_CRM_Outlet_Type__c+sp.EUR_CRM_Segmentation__c, sp);
                }
            }
            
            System.debug('Flag - ServicePack Map:' + spMap);
            for(Id prosSegKey: prosSegServicePackUpdate.keySet()){
                EUR_CRM_Pros_Segmentation__c ps = prosSegServicePackUpdate.get(prosSegKey);
                //String tempSpKey = ps.EUR_CRM_Affiliate__c+ ps.EUR_CRM_Group_Outlet_Type__c + ps.EUR_CRM_Image_Level__c;
                String tempSpKey = ps.EUR_CRM_Country_Code__c + String.valueOf(ps.EUR_CRM_Group_Outlet_Type__c) + String.valueOf(ps.EUR_CRM_Image_Level__c);
                System.debug('Flag - is Service pack found: ' + spMap.containsKey(tempSpKey) + '|' + tempSpKey);
                if(spMap.containsKey(tempSpKey)){
                    //Update Pros Seg Service Pack;
                    ps.EUR_CRM_Service_Pack__c = spMap.get(tempSpKey).Id;
                }else{
                    ps.EUR_CRM_Service_Pack__c = null;
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
                System.debug('EUR_CRM_ProsSegmentationTrigger Update Error: ' + e);
                Database.rollback(pSavepoint);                
            }
        }
        
        //Reset Group Outlet Type dependent objects
        if(prosToUpdateMap.size()>0){
            System.Savepoint pSavepoint = Database.setSavepoint();
            try{
                Database.SaveResult[] updateResults;
                Database.Deleteresult[] deleteImageLevelResults;
                Database.Deleteresult[] deleteVolumePotentialResults;
                
                List<EUR_CRM_Pros_Image_Level__c> tempImageLevels = [SELECT Id 
                                                            from EUR_CRM_Pros_Image_Level__c 
                                                            WHERE EUR_CRM_Pros_Segmentation__c IN:prosToUpdateMap.keySet()];
                //get Prod Volume Potential
                List<EUR_CRM_Pros_Volume_Potential__c> tempVolumePotentials = [SELECT Id 
                                                                from EUR_CRM_Pros_Volume_Potential__c 
                                                                WHERE EUR_CRM_Pros_Segmentation__c IN:prosToUpdateMap.keySet()];
    
                if(tempImageLevels.size()>0){
                    deleteImageLevelResults = Database.delete(tempImageLevels);
                }
                System.debug('EUR_CRM_ProsSegmentationTrigger DELETE IMGAE RESULT: ' + deleteImageLevelResults);
                if(tempVolumePotentials.size()>0){
                    deleteVolumePotentialResults = Database.delete(tempVolumePotentials);
                }
                System.debug('EUR_CRM_ProsSegmentationTrigger DELETE VOLUME RESULT: ' + deleteVolumePotentialResults);
                if(prosToUpdateMap.size()>0){
                    updateResults = Database.update(prosToUpdateMap.values());
                }
                System.debug('EUR_CRM_ProsSegmentationTrigger UPDATE RESULT: ' + updateResults);
                
                //Update Volume Potential base on Volume Card
                EUR_CRM_ProsSegmentationClass.assignVolumePotential(prosToUpdateMap.values(), EUR_CRM_ProsSegmentationClass.returnIdCardMap(accountIdSet));
            }
            catch(Exception e){
                System.debug('EUR_CRM_ProsSegmentationTrigger Update Error: ' + e);
                Database.rollback(pSavepoint);                  
            }
        }
    }
    //Added to set/reset Pros fields in EU Account Object
    if (trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
       Set<Id> euAccountIdSet = new Set<Id>();
       Set<Id> standardAccountIdSet = new Set<Id>();
       Set<Id> prosIdSet = new Set<Id>();
        
        for (EUR_CRM_Pros_Segmentation__c pros:  trigger.new){
            euAccountIdSet.add(pros.EUR_CRM_Account__c);  
            if (pros.EUR_CRM_Standard_Account__c != null){
                standardAccountIdSet.add(pros.EUR_CRM_Standard_Account__c);
                prosIdSet.add(pros.Id);
            }
        }
        Map<Id,EUR_CRM_Account__c> euAccountMap = new Map<Id,EUR_CRM_Account__c>([select id, 
                eur_crm_force_iconic_account__c,
                EUR_CRM_Group_Outlet_Type__c,
                EUR_CRM_Outlet_Type__c,
                EUR_CRM_Image_Level__c,
                EUR_CRM_Volume_Potential__c
                from eur_crm_account__c where id in: euAccountIdSet]);
        system.debug('@@euAccountIdSet' + euAccountIdSet);
        system.debug('@@standardAccountIdSet' + standardAccountIdSet);

        Map<Id,EUR_CRM_Account__c> toUpdateEUAccountList = new Map<Id,EUR_CRM_Account__c>();        
        Map<Id,Account> standardAccountMap = new Map<Id,Account>();
        Map<Id,EUR_CRM_Pros_Segmentation__c> prosMap = new Map<Id,EUR_CRM_Pros_Segmentation__c>();

        if (standardAccountIdSet.size()>0){
            standardAccountMap = new Map<Id,Account>([SELECT Id, EUR_CRM_Group_Outlet_Type__c,
                                                        EUR_CRM_Outlet_Type__c, EUR_CRM_Image_Level__c,
                                                        EUR_CRM_Volume_Potential__c 
                                                        FROM Account 
                                                        WHERE Id IN:standardAccountIdSet]);
            
            prosMap = new Map<Id,EUR_CRM_Pros_Segmentation__c>([SELECT Id, 
                                                        EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Name__c,
                                                        EUR_CRM_Outlet_Type__r.EUR_CRM_Name__c, 
                                                        EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c,
                                                        EUR_CRM_Volume_Potential_Threshold__r.EUR_CRM_Volume_Potential_Name__c 
                                                        FROM EUR_CRM_Pros_Segmentation__c 
                                                        WHERE Id IN:prosIdSet]);
        }
        Map<Id,Account> toUpdateStandardAccountList = new Map<Id,Account>();
        
        for (EUR_CRM_Pros_Segmentation__c pros: trigger.new){

            //check if PRT, if it is. use the standard account else use the custom eu account
            if(pros.eur_crm_country_code__c == 'PRT'){
                Account stdAccount = standardAccountMap.get(pros.EUR_CRM_Standard_Account__c);
                EUR_CRM_Pros_Segmentation__c prosDet = prosMap.get(pros.Id);

                if ( stdAccount!=null && prosDet != null &&
                    (stdAccount.EUR_CRM_Group_Outlet_Type__c != prosDet.EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Name__c ||
                     stdAccount.EUR_CRM_Outlet_Type__c != prosDet.EUR_CRM_Outlet_Type__r.EUR_CRM_Name__c ||
                     stdAccount.EUR_CRM_Image_Level__c != prosDet.EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c ||
                     stdAccount.EUR_CRM_Volume_Potential__c != prosDet.EUR_CRM_Volume_Potential_Threshold__r.EUR_CRM_Volume_Potential_Name__c)){
                    
                    stdAccount.EUR_CRM_Group_Outlet_Type__c = prosDet.EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Name__c;
                    stdAccount.EUR_CRM_Outlet_Type__c = prosDet.EUR_CRM_Outlet_Type__r.EUR_CRM_Name__c;
                    stdAccount.EUR_CRM_Image_Level__c = prosDet.EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c;
                    stdAccount.EUR_CRM_Volume_Potential__c = prosDet.EUR_CRM_Volume_Potential_Threshold__r.EUR_CRM_Volume_Potential_Name__c ;
                    
                    toUpdateStandardAccountList.put(stdAccount.Id, stdAccount);
                }
                continue;
            }  
            
            EUR_CRM_Account__c euAccount = euAccountMap.get(pros.EUR_CRM_Account__c);
            if(euAccount != null && isPROSChanged(pros, Trigger.oldMap.get(pros.Id)) &&
                prosToUpdateMap.size() == 0 &&
                (euAccount.EUR_CRM_Group_Outlet_Type__c != pros.EUR_CRM_Group_Outlet_Type__c ||
                euAccount.EUR_CRM_Outlet_Type__c != pros.EUR_CRM_Outlet_Type__c ||
                euAccount.EUR_CRM_Image_Level__c != pros.EUR_CRM_Image_Level_Id__c ||
                euAccount.EUR_CRM_Volume_Potential__c != pros.EUR_CRM_Volume_Potential_Id__c)){

                euAccount.EUR_CRM_Group_Outlet_Type__c = pros.EUR_CRM_Group_Outlet_Type__c;
                euAccount.EUR_CRM_Outlet_Type__c = pros.EUR_CRM_Outlet_Type__c;
                euAccount.EUR_CRM_Image_Level__c = pros.EUR_CRM_Image_Level_Id__c;
                euAccount.EUR_CRM_Volume_Potential__c = pros.EUR_CRM_Volume_Potential_Id__c;
                toUpdateEUAccountList.put(euAccount.id,euAccount); 

            }

        system.debug('pros' + pros);
        system.debug('oldPROS' + Trigger.oldMap.get(pros.Id));
  

        }
        
        system.debug('toUpdateEUAccountList' + toUpdateEUAccountList);

        if (toUpdateEUAccountList.size() > 0){
            //update toUpdateEUAccountList.values();
            EUR_CRM_CommonRoutine.dmlWithPartialSuccess('update', toUpdateEUAccountList.values());
        }
        if (toUpdateStandardAccountList.size()>0){
            EUR_CRM_CommonRoutine.dmlWithPartialSuccess('update', toUpdateStandardAccountList.values());
            //update toUpdateStandardAccountList.values();
        }
    }

    private Boolean isPROSChanged(EUR_CRM_Pros_Segmentation__c newPROS, EUR_CRM_Pros_Segmentation__c oldPROS){
        if(oldPROS == null ) return false;
        return   (oldPROS.EUR_CRM_Group_Outlet_Type__c != newPROS.EUR_CRM_Group_Outlet_Type__c ||
                    oldPROS.EUR_CRM_Outlet_Type__c != newPROS.EUR_CRM_Outlet_Type__c ||
                    oldPROS.EUR_CRM_Image_Level_Id__c != newPROS.EUR_CRM_Image_Level_Id__c ||
                    oldPROS.EUR_CRM_Volume_Potential_Id__c != newPROS.EUR_CRM_Volume_Potential_Id__c);
    }
}