/*********************************************************************************
 * Name:ASI_BRD_Generic_AccountTerritory
 * Description: Update Territories for Account
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 22/09/2015       Laputa: Hank          Created
 * 25/03/2016       IPC: DC               Addded and removed debugs to find reason behind territory not getting assigned on insert.
*********************************************************************************/

public with sharing class ASI_BRD_Generic_AccountTerritory extends ASI_BRD_Generic_TriggerAbstract {

    public ASI_BRD_Generic_AccountTerritory() {
        super('ASI_BRD_Generic_AccountTerritory');
    }
    public Map<String, List<Territory2>> ttMap = new Map<String, List<Territory2>>();
    List<ObjectTerritory2Association> newTTToAssign = new List<ObjectTerritory2Association>();
    List<ObjectTerritory2Association> oldTTToDelete = new List<ObjectTerritory2Association>();
    Map<String, ObjectTerritory2Association> existTTMap = new Map<String, ObjectTerritory2Association>();
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
        List<Account> accList = (List<Account>)sObjList;
        Set<Id> ttIdSet = new Set<Id>();
        for(ObjectTerritory2Association o:[Select Id, Territory2Id, ObjectId From ObjectTerritory2Association Where ObjectId = :accList and AssociationCause = 'Territory2Manual']){
            existTTMap.put(o.ObjectId + '-' + o.Territory2Id, o);
        }
        for(Territory2 t:[Select Id, Name, ASI_BRD_Primary_Market__c, DeveloperName From Territory2]){
            ttIdSet.add(t.Id);
            if(ttMap.get(t.ASI_BRD_Primary_Market__c) == null){
                List<Territory2> tempTTList = new List<Territory2>();
                tempTTList.add(t);
                ttMap.put(t.ASI_BRD_Primary_Market__c, tempTTList);
            }else{
                ttMap.get(t.ASI_BRD_Primary_Market__c).add(t);
            } 
        }
        if(oldMap == null){
             for(Account acc:accList){
                if(acc.ASI_BRD_Absolut_Engaged__pc == 'Yes'){
                    updateTerritory(acc,'Absolut',null, acc.ASI_BRD_Absolut_Engaged__pc);   
                }
                if(acc.ASI_BRD_Ballantines_Engaged__pc == 'Yes'){
                    updateTerritory(acc,'Ballantines',null, acc.ASI_BRD_Ballantines_Engaged__pc);  
                }
                if(acc.ASI_BRD_GHMumm_Engaged__pc == 'Yes'){
                    updateTerritory(acc,'GHMumm',null, acc.ASI_BRD_GHMumm_Engaged__pc);  
                }
                if(acc.ASI_BRD_Martell_Engaged__pc == 'Yes'){
                    updateTerritory(acc,'Martell',null, acc.ASI_BRD_Martell_Engaged__pc);    
                }
                if(acc.ASI_BRD_PerrierJouet_Engaged__pc == 'Yes'){
                    updateTerritory(acc,'PerrierJouet',null, acc.ASI_BRD_PerrierJouet_Engaged__pc);     
                }
                if(acc.ASI_BRD_RoyalSalute_Engaged__pc == 'Yes'){
                    updateTerritory(acc,'RoyalSalute',null, acc.ASI_BRD_RoyalSalute_Engaged__pc);     
                }
                if(acc.ASI_BRD_TheGlenlivet_Engaged__pc == 'Yes'){
                    updateTerritory(acc,'TheGlenlivet',null, acc.ASI_BRD_TheGlenlivet_Engaged__pc);    
                }
                if(acc.ASI_BRD_OtherBrand1_Engaged__pc == 'Yes'){
                    updateTerritory(acc,acc.ASI_BRD_Name_of_OtherBrand1__pc,null, acc.ASI_BRD_OtherBrand1_Engaged__pc);    
                }
                if(acc.ASI_BRD_OtherBrand2_Engaged__pc == 'Yes'){
                    updateTerritory(acc,acc.ASI_BRD_Name_of_OtherBrand2__pc, null, acc.ASI_BRD_OtherBrand2_Engaged__pc);    
                }
                if(acc.ASI_BRD_OtherBrand3_Engaged__pc == 'Yes'){
                    updateTerritory(acc,acc.ASI_BRD_Name_of_OtherBrand3__pc, null, acc.ASI_BRD_OtherBrand3_Engaged__pc);    
                }
                //BRD CRM P2
                if(acc.ASI_BRD_Beefeater_Engaged__pc == 'Yes'){
                    updateTerritory(acc,'Beefeater', null, acc.ASI_BRD_Beefeater_Engaged__pc);    
                }
                if(acc.ASI_BRD_Chivas_Engaged__pc == 'Yes'){
                    updateTerritory(acc,'Chivas', null, acc.ASI_BRD_Chivas_Engaged__pc);    
                }
                if(acc.ASI_BRD_HavanaClub_Engaged__pc == 'Yes'){
                    updateTerritory(acc,'Havana', null, acc.ASI_BRD_HavanaClub_Engaged__pc);    
                }
                if(acc.ASI_BRD_Jameson_Engaged__pc == 'Yes'){
                    updateTerritory(acc,'Jameson', null, acc.ASI_BRD_Jameson_Engaged__pc);    
                }
                if(acc.ASI_BRD_Kahlua_Engaged__pc == 'Yes'){
                    updateTerritory(acc,'Kahlua', null, acc.ASI_BRD_Kahlua_Engaged__pc);    
                }
                if(acc.ASI_BRD_Malibu_Engaged__pc == 'Yes'){
                    updateTerritory(acc,'Malibu', null, acc.ASI_BRD_Malibu_Engaged__pc);    
                }
                if(acc.ASI_BRD_Ricard_Engaged__pc == 'Yes'){
                    updateTerritory(acc,'Ricard', null, acc.ASI_BRD_Ricard_Engaged__pc);    
                }
            }
        }else{
            Map<Id, Account> oldAccMap = (Map<Id, Account>) oldMap;
            for(Account acc:accList){
                if(acc.ASI_BRD_Absolut_Engaged__pc != oldAccMap.get(acc.Id).ASI_BRD_Absolut_Engaged__pc){
                    updateTerritory(acc,'Absolut',oldAccMap.get(acc.Id).ASI_BRD_Absolut_Engaged__pc, acc.ASI_BRD_Absolut_Engaged__pc);   
                }
                if(acc.ASI_BRD_Ballantines_Engaged__pc != oldAccMap.get(acc.Id).ASI_BRD_Ballantines_Engaged__pc){
                    updateTerritory(acc,'Ballantines',oldAccMap.get(acc.Id).ASI_BRD_Ballantines_Engaged__pc, acc.ASI_BRD_Ballantines_Engaged__pc);  
                }
                if(acc.ASI_BRD_GHMumm_Engaged__pc != oldAccMap.get(acc.Id).ASI_BRD_GHMumm_Engaged__pc){
                    updateTerritory(acc,'GHMumm',oldAccMap.get(acc.Id).ASI_BRD_GHMumm_Engaged__pc, acc.ASI_BRD_GHMumm_Engaged__pc);  
                }
                if(acc.ASI_BRD_Martell_Engaged__pc != oldAccMap.get(acc.Id).ASI_BRD_Martell_Engaged__pc){
                    updateTerritory(acc,'Martell',oldAccMap.get(acc.Id).ASI_BRD_Martell_Engaged__pc, acc.ASI_BRD_Martell_Engaged__pc);    
                }
                if(acc.ASI_BRD_PerrierJouet_Engaged__pc != oldAccMap.get(acc.Id).ASI_BRD_PerrierJouet_Engaged__pc){
                    updateTerritory(acc,'PerrierJouet',oldAccMap.get(acc.Id).ASI_BRD_PerrierJouet_Engaged__pc, acc.ASI_BRD_PerrierJouet_Engaged__pc);     
                }
                if(acc.ASI_BRD_RoyalSalute_Engaged__pc != oldAccMap.get(acc.Id).ASI_BRD_RoyalSalute_Engaged__pc){
                    updateTerritory(acc,'RoyalSalute',oldAccMap.get(acc.Id).ASI_BRD_RoyalSalute_Engaged__pc, acc.ASI_BRD_RoyalSalute_Engaged__pc);     
                }
                if(acc.ASI_BRD_TheGlenlivet_Engaged__pc != oldAccMap.get(acc.Id).ASI_BRD_TheGlenlivet_Engaged__pc){
                    updateTerritory(acc,'TheGlenlivet',oldAccMap.get(acc.Id).ASI_BRD_TheGlenlivet_Engaged__pc, acc.ASI_BRD_TheGlenlivet_Engaged__pc);    
                }
                if(acc.ASI_BRD_OtherBrand1_Engaged__pc != oldAccMap.get(acc.Id).ASI_BRD_OtherBrand1_Engaged__pc){
                    updateTerritory(acc,acc.ASI_BRD_Name_of_OtherBrand1__pc,oldAccMap.get(acc.Id).ASI_BRD_OtherBrand1_Engaged__pc, acc.ASI_BRD_OtherBrand1_Engaged__pc);    
                }
                if(acc.ASI_BRD_OtherBrand2_Engaged__pc != oldAccMap.get(acc.Id).ASI_BRD_OtherBrand2_Engaged__pc){
                    updateTerritory(acc,acc.ASI_BRD_Name_of_OtherBrand2__pc,oldAccMap.get(acc.Id).ASI_BRD_OtherBrand2_Engaged__pc, acc.ASI_BRD_OtherBrand2_Engaged__pc);    
                }
                if(acc.ASI_BRD_OtherBrand3_Engaged__pc != oldAccMap.get(acc.Id).ASI_BRD_OtherBrand3_Engaged__pc){
                    updateTerritory(acc,acc.ASI_BRD_Name_of_OtherBrand3__pc,oldAccMap.get(acc.Id).ASI_BRD_OtherBrand3_Engaged__pc, acc.ASI_BRD_OtherBrand3_Engaged__pc);    
                }
                //BRD CRM P2
                if(acc.ASI_BRD_Beefeater_Engaged__pc != oldAccMap.get(acc.Id).ASI_BRD_Beefeater_Engaged__pc){
                    updateTerritory(acc,'Beefeater',oldAccMap.get(acc.Id).ASI_BRD_Beefeater_Engaged__pc, acc.ASI_BRD_Beefeater_Engaged__pc);    
                }
                if(acc.ASI_BRD_Chivas_Engaged__pc != oldAccMap.get(acc.Id).ASI_BRD_Chivas_Engaged__pc){
                    updateTerritory(acc,'Chivas',oldAccMap.get(acc.Id).ASI_BRD_Chivas_Engaged__pc, acc.ASI_BRD_Chivas_Engaged__pc);    
                }
                if(acc.ASI_BRD_HavanaClub_Engaged__pc != oldAccMap.get(acc.Id).ASI_BRD_HavanaClub_Engaged__pc){
                   updateTerritory(acc,'Havana',oldAccMap.get(acc.Id).ASI_BRD_HavanaClub_Engaged__pc, acc.ASI_BRD_HavanaClub_Engaged__pc);    
                }
                if(acc.ASI_BRD_Jameson_Engaged__pc != oldAccMap.get(acc.Id).ASI_BRD_Jameson_Engaged__pc){
                    updateTerritory(acc,'Jameson',oldAccMap.get(acc.Id).ASI_BRD_Jameson_Engaged__pc, acc.ASI_BRD_Jameson_Engaged__pc);    
                }
                if(acc.ASI_BRD_Kahlua_Engaged__pc != oldAccMap.get(acc.Id).ASI_BRD_Kahlua_Engaged__pc){
                    updateTerritory(acc,'Kahlua',oldAccMap.get(acc.Id).ASI_BRD_Kahlua_Engaged__pc, acc.ASI_BRD_Kahlua_Engaged__pc);    
                }
                if(acc.ASI_BRD_Malibu_Engaged__pc != oldAccMap.get(acc.Id).ASI_BRD_Malibu_Engaged__pc){
                    updateTerritory(acc,'Malibu',oldAccMap.get(acc.Id).ASI_BRD_Malibu_Engaged__pc, acc.ASI_BRD_Malibu_Engaged__pc);    
                }
                if(acc.ASI_BRD_Ricard_Engaged__pc != oldAccMap.get(acc.Id).ASI_BRD_Ricard_Engaged__pc){
                    updateTerritory(acc,'Ricard',oldAccMap.get(acc.Id).ASI_BRD_Ricard_Engaged__pc, acc.ASI_BRD_Ricard_Engaged__pc);    
                }
            }
        }
        if(newTTToAssign.size() > 0){
            Database.insert(newTTToAssign, false);
        }
        if(oldTTToDelete.size() > 0){
            Database.delete(oldTTToDelete, false);
        }
    }
    
    private void updateTerritory(Account acc, String prefix, String oldValue, String newValue){

        if(oldValue != newValue && newValue == 'Yes' && acc.ASI_BRD_Primary_Market__pc != null && ttMap.get(acc.ASI_BRD_Primary_Market__pc) != null){
            for(Territory2 t:ttMap.get(acc.ASI_BRD_Primary_Market__pc)){
                if(t.Name.contains(prefix) || t.developerName.contains(prefix)){
                    ObjectTerritory2Association share = new ObjectTerritory2Association(ObjectId = acc.Id, AssociationCause = 'Territory2Manual', Territory2Id = t.Id);
                    newTTToAssign.add(share);
                    system.debug('Added: ' + share);
                }
            }
            
        }else if(oldValue == 'Yes' && newValue != oldValue && acc.ASI_BRD_Primary_Market__pc != null && ttMap.get(acc.ASI_BRD_Primary_Market__pc) != null){
            for(Territory2 t:ttMap.get(acc.ASI_BRD_Primary_Market__pc)){
                if(t.Name.contains(prefix) || t.developerName.contains(prefix)){
                    if(existTTMap.get(acc.Id + '-' + t.Id) != null){
                        oldTTToDelete.add(existTTMap.get(acc.Id + '-' + t.Id));
                        system.debug(existTTMap.get(acc.Id + '-' + t.Id));
                    }
                }
            }
        }   
    }
}