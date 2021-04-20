public with sharing class EUR_CRM_ForceIconicAccountHandler extends EUR_CRM_TriggerAbstract {
   
    public EUR_CRM_ForceIconicAccountHandler(){
        super('EUR_CRM_ForceIconicAccountHandler');
    }
     
    private static Set<String> euAccountRecordTypeSet = new Set<String>{
      'EUR_GB_FS_Blitz',
      'EUR_GB_FS_Indirect',
      'EUR_GB_FS_RTM',
      'EUR_GB_Indies',
      'EUR_E1_On_Trade',
      'EUR_DE_ON_Gastronomy',
      'EUR_EE_DIR_ON_Trade',
      'EUR_EE_INDIR_ON_Trade',
      'EUR_LT_DIR_ON_Trade',
      'EUR_LT_INDIR_OFF_Trade',
      'EUR_LV_DIR_ON_Trade',
      'EUR_LV_INDIR_ON_Trade',
      'EUR_AT_On_Trade',
      'EUR_KE_On_Trade',
      'EUR_AO_On_Trade',
      'EUR_MA_On_Trade',
      'EUR_RU_On_Trade',
      'EUR_CH_Horeca_Indirect',
      'EUR_CH_Horeca_Direct',
      'EUR_BG_On_Trade',
      'EUR_ZA_On_Trade_Informal',
      'EUR_ZA_On_Trade_Indirect',
      'EUR_ZA_On_Trade_Direct',
      'EUR_ZA_Off_Trade'
    };

    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            TRt.addAll(euAccountRecordTypeSet);
            
            return TRt;
        }private set;
    }


    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        if( runOnce() ) {
            system.debug('account :)');
            processEUAccounts(tAction, (List<EUR_CRM_Account__c>) sObjList, (Map<ID, EUR_CRM_Account__c>) newMap, (Map<ID, EUR_CRM_Account__c>) oldMap);
        } 
    }
    /**
    
    */    
    private void processEUAccounts(TriggerAction tAction, List<EUR_CRM_Account__c> sObjList, Map<ID, EUR_CRM_Account__c> newMap,Map<ID, EUR_CRM_Account__c> oldMap){
      System.Debug('EUR_CRM_ForceIconicAccountHandler');
        List<Recordtype> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        Map<Id,Recordtype> accountRecordTypesMap = new Map<Id,Recordtype>();
        
        for(Recordtype rt : accountRecordTypes){
           accountRecordTypesMap.put(rt.id,rt);
        }
        Map<String,Id> countryImageLevelIconicMap = new Map<String,Id>();
        
       Set<Id> euAccounts = new Set<Id>();
       Map<Id,EUR_CRM_Pros_Segmentation__c> prosMap = new Map<Id,EUR_CRM_Pros_Segmentation__c>(); 
       
       for(EUR_CRM_Account__c euAccount : sObjList){ 
           if(euAccountRecordTypeSet.contains(accountRecordTypesMap.get(euAccount.RecordtypeId).DeveloperName)){
              if(tAction == TriggerAction.BEFORE_INSERT && euAccount.eur_crm_force_iconic_account__c){
                  euAccounts.add(euAccount.id);
              }else if(tAction == TriggerAction.BEFORE_UPDATE  &&
                (oldMap.get(euAccount.id).eur_crm_force_iconic_account__c != euAccount.eur_crm_force_iconic_account__c ||
                oldMap.get(euAccount.id).eur_crm_image_level__c != euAccount.eur_crm_image_level__c)){
                  euAccounts.add(euAccount.id);
              } 
           }
       }
       if(euAccounts.size()>0){
           
            for(eur_crm_image_level__c imageLevel: [select id,eur_crm_country_code__c from eur_crm_image_level__c where eur_crm_name__c = 'ICONIC']){
                countryImageLevelIconicMap.put(imageLevel.eur_crm_country_code__c,imageLevel.id);
            }
           for(EUR_CRM_Pros_Segmentation__c pros : 
           [select id,EUR_CRM_Account__c , EUR_CRM_Image_Level_Threshold__c, EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level__c from EUR_CRM_Pros_Segmentation__c
           where EUR_CRM_Account__c =: euAccounts]){
               prosMap.put(pros.EUR_CRM_Account__c , pros);
           }
       }
       for(Id key : euAccounts){
           EUR_CRM_Account__c euAccount = newMap.get(key); 
           if(euAccount.eur_crm_force_iconic_account__c){
            euAccount.eur_crm_image_level__c = countryImageLevelIconicMap.get(euAccount.eur_crm_country_code__c); 
           }else{
              if(prosMap.get(euAccount.id) != null && prosMap.get(euAccount.id).EUR_CRM_Image_Level_Threshold__c != null)
                euAccount.eur_crm_image_level__c = prosMap.get(euAccount.id).EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level__c;             
          } 
       } 
     
    }
    
    
    
    private static boolean run = true;
    
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
}