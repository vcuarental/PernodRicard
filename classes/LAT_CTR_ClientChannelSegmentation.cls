/*************************************************************************************************
*                           Company: ValueNet
*-------------------------------------------------------------------------------------------------
*   Clase que distribuye los registros por pais del objeto LAT_BR_ClientChannelSegmentation__c
**************************************************************************************************/
public with sharing class LAT_CTR_ClientChannelSegmentation {
    
    /*ALL TRIGGERS*/
    public static void runTriggers(){
        
        //On Trade Brazil
        LAT_Trigger trigger_OnBR = new LAT_Trigger('LAT_BR_ClientChannelSegmentation__c', new set<String>{'LAT_BR_CCS_OnTrade'});
        triggersOnBR(trigger_OnBR);
        
        //Off Trade Brazil
        LAT_Trigger trigger_OffBR = new LAT_Trigger('LAT_BR_ClientChannelSegmentation__c', new set<String>{'LAT_BR_CCS_OffTrade'});
        triggersOffBR(trigger_OffBR);
        
        //All Brazil
        LAT_Trigger trigger_AllBR = new LAT_Trigger('LAT_BR_ClientChannelSegmentation__c', new set<String>{'LAT_BR_CCS_OffTrade','LAT_BR_CCS_OnTrade'});
        triggersAllBR(trigger_AllBR);
    }
    
    /*TRIGGERS On trade BR*/
    private static void triggersOnBR(LAT_Trigger trigger_OnBR){
        //Before
        if(trigger.isBefore){
            if(trigger.isInsert){
                if(!trigger_OnBR.getNew().IsEmpty()){
                    LAT_BR_AP01_ClientChannelSegment.ObtainedSubChannelOnTrade(trigger_OnBR.getNew());
                }
            }
            if(trigger.isUpdate){
                if(!trigger_OnBR.getNew().IsEmpty()){
                    LAT_BR_AP01_ClientChannelSegment.ObtainedSubChannelOnTrade(trigger_OnBR.getNew());
                }
            }
        }
        //After
        if(trigger.isAfter){
            if(trigger.isInsert){
                if(!trigger_OnBR.getNew().IsEmpty()){
                    LAT_BR_AP01_ClientChannelSegment.AccUpdaterFromSegOn(trigger_OnBR.getNew(), null);
                }
            }
            if(trigger.isUpdate){
                if(!trigger_OnBR.getNew().IsEmpty()){
                    LAT_BR_AP01_ClientChannelSegment.AccUpdaterFromSegOn(trigger_OnBR.getNew(), new map<Id,LAT_BR_ClientChannelSegmentation__c>((List<LAT_BR_ClientChannelSegmentation__c>)trigger_OnBR.getOld()));
                }
            }
            if(trigger.isDelete){
            }
        }
    }
    
    /*TRIGGERS Off trade BR*/
    private static void triggersOffBR(LAT_Trigger trigger_OffBR){
        //Before
        if(trigger.isBefore){
            if(trigger.isInsert){
                if(!trigger_OffBR.getNew().IsEmpty()){
                    LAT_BR_AP01_ClientChannelSegment.ObtainedForOffTrade(trigger_OffBR.getNew(), null);
                }
            }
            if(trigger.isUpdate){
                if(!trigger_OffBR.getNew().IsEmpty()){
                    LAT_BR_AP01_ClientChannelSegment.ObtainedForOffTrade(trigger_OffBR.getNew(), new map<Id,LAT_BR_ClientChannelSegmentation__c>((List<LAT_BR_ClientChannelSegmentation__c>)trigger_OffBR.getOld()));
                }
            }
        }
        //After
        if(trigger.isAfter){
            if(trigger.isInsert){
                if(!trigger_OffBR.getNew().IsEmpty()){
                    LAT_BR_AP01_ClientChannelSegment.AccUpdaterFromSegOff(trigger_OffBR.getNew(), null);
                }
            }
            if(trigger.isUpdate){
                if(!trigger_OffBR.getNew().IsEmpty()){
                    LAT_BR_AP01_ClientChannelSegment.AccUpdaterFromSegOff(trigger_OffBR.getNew(), new map<Id,LAT_BR_ClientChannelSegmentation__c>((List<LAT_BR_ClientChannelSegmentation__c>)trigger_OffBR.getOld()));
                }
            }
            if(trigger.isDelete){
            }
        }
    }
    
    /*TRIGGERS All BR*/
    private static void triggersAllBR(LAT_Trigger trigger_AllBR){
        //Before
        if(trigger.isBefore){
            if(trigger.isInsert){
                if(!trigger_AllBR.getNew().IsEmpty()){
                    LAT_BR_AP01_ClientChannelSegment.updatesAreaRegionalManager(trigger_AllBR.getNew());
                    LAT_BR_AP01_ClientChannelSegment.updatesStatus(trigger_AllBR.getNew());
                }
            }
            if(trigger.isDelete){
                if(!trigger_AllBR.getOld().IsEmpty()){
                    LAT_BR_AP01_ClientChannelSegment.validatesDelete(trigger_AllBR.getOld());
                }
            }
        }
        //After
        if(trigger.isAfter){

        }
    }
}