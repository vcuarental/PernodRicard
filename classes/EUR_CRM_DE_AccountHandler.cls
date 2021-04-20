/**

Functions:
    - O/P Account mapping handler: Update o/p account mapping if.
    1. account insert and customer taxonomy/PROS has an active OP 
        - create op-account mapping
    2. account update and customer taxonomy/PROS has an active op
        - create op-account mapping
        - and if previous customer taxonomy/PROS has an acive op, delete previous op mapping
    3. account insert or update if customer status changes from active to inactive or vice versa
        - delete existing related account op-account mappings if account status changes to 'Inactive'
        - insert op-account mapping if account status changes to 'Active'
        
*   Edit Oct.24.2014
*   - Change source of Customer Taxonomy from field, EUR_CRM_ObjPromo__c.EUR_CRM_Customer_Taxonomy__c, to junction object EUR_CRM_OP_Customer_Taxonomy_Mapping__c
*   Edit Feb.09.2015
    - 
*/
public without sharing class EUR_CRM_DE_AccountHandler  extends EUR_CRM_TriggerAbstract {
    
    private static final Set<String> allGermnayAccountRecordTypeSet = new Set<String>{
      'EUR_DE_ON_Consumers',
      'EUR_DE_ON_Enquiry_Acquisition',
      'EUR_DE_ON_Gastronomy',
      'EUR_DE_ON_Service_agency',
      'EUR_DE_ON_Wholesaler',
      'EUR_DE_OFF_STD'
    };
    private static final Set<String> onTradeGermnayAccountRecordTypeSet = new Set<String>{
      'EUR_DE_ON_Consumers',
      'EUR_DE_ON_Enquiry_Acquisition',
      'EUR_DE_ON_Gastronomy',
      'EUR_DE_ON_Service_agency',
      'EUR_DE_ON_Wholesaler'
    };
    
    private static final Set<String> offTradeGermnayAccountRecordTypeSet = new Set<String>{ 
      'EUR_DE_OFF_STD'
    };
     private final Set<String> validStatus = new Set<String>{ 
      'Active', 'Agency Managed', 'Potential customer', 'New customer'
    };
    /*
        insert new op - account mappings if
        new account and taxonomy has active op-
    */

    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            TRt.addAll(allGermnayAccountRecordTypeSet);

            return TRt;
        }private set;
    }
    
    private Map<Id,EUR_CRM_Territory__c> territoryMap = new Map<Id,EUR_CRM_Territory__c>(); 
    private final String ACTIVE = 'Active';
    private final String INACTIVE = 'Inactive';
    public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap){
        List<Recordtype> accountRecordTypes = Global_RecordTypeCache.getRtList('EUR_CRM_Account__c');
        Map<Id,Recordtype> accountRecordTypesMap = new Map<Id,Recordtype>();
        
        for(Recordtype rt : accountRecordTypes){
           accountRecordTypesMap.put(rt.id,rt);
        }
        List<EUR_CRM_Account__c> validAccounts = new List<EUR_CRM_Account__c>(); 
        Set<Id> validAccountIds = new Set<Id>();
        Set<Id> validOnTradeAccountIds = new Set<Id>();
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountToinsert = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountToupdate = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountTodelete = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        Set<Id> customerTaxonomyIds = new Set<Id>();
        Map<Id,Set<Id>> accountObjectivesMap = new Map<Id,Set<Id>>();
        Map<String,Id> opamap = new Map<String,Id>();
        
        Set<String> regions = new Set<String>();
        Set<String> territories = new Set<String>();
        Set<String> groupOutlets = new Set<String>();
        Set<String> imageLevels = new Set<String>();
        Set<Id> territoryIds = new Set<Id>();
        
        Id tastingOpId = [Select Id FROM Recordtype WHERE SObjectType = 'EUR_CRM_ObjPromo__c' AND DeveloperName = 'EUR_DE_Off_Trade_Tasting_Campaign'].Id;
        
        for(EUR_CRM_Account__c euAccount : (List<EUR_CRM_Account__c>) sObjList){
            if(offTradeGermnayAccountRecordTypeSet.contains(accountRecordTypesMap.get(euAccount.recordtypeid).developername)){
                validAccounts.add(euAccount);
                validAccountIds.add(euAccount.id);
                if(euAccount.EUR_JB_Customer_Taxonomy__c!=null)
                    customerTaxonomyIds.add(euAccount.EUR_JB_Customer_Taxonomy__c);
                if(Trigger.IsUpdate && isChanged(euAccount  ,((EUR_CRM_Account__c ) oldMap.get(euAccount.id)),false ) && ((EUR_CRM_Account__c ) oldMap.get(euAccount.id)).EUR_JB_Customer_Taxonomy__c!=null)  
                 {   
                 system.debug('++ cTax: ' +((EUR_CRM_Account__c )oldMap.get(euAccount.id)).EUR_JB_Customer_Taxonomy__c );
                 customerTaxonomyIds.add(((EUR_CRM_Account__c )oldMap.get(euAccount.id)).EUR_JB_Customer_Taxonomy__c);  
                }                
            }
            else if(onTradeGermnayAccountRecordTypeSet.contains(accountRecordTypesMap.get(euAccount.recordtypeid).developername)){
                validAccounts.add(euAccount);
                validAccountIds.add(euAccount.id);
                validOnTradeAccountIds.add(euAccount.id);
                if(euAccount.EUR_CRM_Territory__c != null)
                    territoryIds.add(euAccount.EUR_CRM_Territory__c);
                groupOutlets.add(euAccount.EUR_CRM_Group_Outlet_Type_Name__c);
                imageLevels.add(euAccount.EUR_CRM_Image_Level_Name__c);
                regions.add(euAccount.EUR_CRM_Region__c);
                if(Trigger.IsUpdate && isChanged(euAccount ,((EUR_CRM_Account__c ) oldMap.get(euAccount.id)),true)){
                    EUR_CRM_Account__c oldEuAccount =  ((EUR_CRM_Account__c ) oldMap.get(euAccount.id));
                    groupOutlets.add(oldEuAccount.EUR_CRM_Group_Outlet_Type_Name__c);
                    imageLevels.add(oldEuAccount.EUR_CRM_Image_Level_Name__c);
                    regions.add(oldEuAccount.EUR_CRM_Region__c);
                    if(oldEuAccount.EUR_CRM_Territory__c != null)
                        territoryIds.add(oldEuAccount.EUR_CRM_Territory__c);
                    
                }
            }
        }
        
        if(validOnTradeAccountIds.size() > 0){
            for(EUR_CRM_Territory__c territory : [select EUR_CRM_Region__r.name, Name from EUR_CRM_Territory__c  where id in: territoryIds]){ 
                territories.add(territory.name);
                territoryMap.put(territory.id,territory);
            }        }
        
        //key = customer taxnomy or key = region + territory + groupoutlet  + image level
        Map<String,Set<Id>> keyToObjectPromoMap = new Map<String,Set<Id>>();
        
        /*
        if(customerTaxonomyIds.size() >0){
            for(EUR_CRM_ObjPromo__c objPromo:[select id,EUR_CRM_Customer_Taxonomy__c from EUR_CRM_ObjPromo__c where EUR_CRM_Customer_Taxonomy__c in:customerTaxonomyIds
                                              AND EUR_CRM_Status__c = 'Active']){
                if(keyToObjectPromoMap.get(objPromo.EUR_CRM_Customer_Taxonomy__c) == null)
                    keyToObjectPromoMap.put(objPromo.EUR_CRM_Customer_Taxonomy__c, new Set<Id>());
                keyToObjectPromoMap.get(objPromo.EUR_CRM_Customer_Taxonomy__c).add(objPromo.id);                
            }       
        }
        */
        Set<Id> opAndPromIds = new Set<Id>();
        //Edit 10/24, New Customer Taxonomy Source
        if(customerTaxonomyIds.size() >0){
            for (EUR_CRM_OP_Customer_Taxonomy_Mapping__c opCustomerMapping : [SELECT Id, EUR_CRM_Customer_Taxonomy__c,
                                                                            EUR_CRM_ObjPromo__c 
                                                                            FROM EUR_CRM_OP_Customer_Taxonomy_Mapping__c
                                                                            WHERE EUR_CRM_Customer_Taxonomy__c IN:customerTaxonomyIds
                                                                            AND EUR_CRM_ObjPromo__r.EUR_CRM_Status__c = 'Active']){
                if(keyToObjectPromoMap.get(opCustomerMapping.EUR_CRM_Customer_Taxonomy__c) == null)
                    keyToObjectPromoMap.put(opCustomerMapping.EUR_CRM_Customer_Taxonomy__c, new Set<Id>());
                keyToObjectPromoMap.get(opCustomerMapping.EUR_CRM_Customer_Taxonomy__c).add(opCustomerMapping.EUR_CRM_ObjPromo__c);
              opAndPromIds.add(opCustomerMapping.EUR_CRM_ObjPromo__c);
            }
        }
        
        
        if(validOnTradeAccountIds.size() >0){
            for(EUR_CRM_ObjPromo__c objPromo:[select id,EUR_CRM_Region__c,EUR_CRM_Territory__c,EUR_CRM_PROS_Group_Outlet__c
              ,   EUR_CRM_PROS_Image_Level__c 
            from EUR_CRM_ObjPromo__c 
            where 
           // EUR_CRM_Region__c in:regions AND EUR_CRM_Territory__c in:territories AND              
             EUR_CRM_PROS_Group_Outlet__c in:groupOutlets 
             AND EUR_CRM_PROS_Image_Level__c in:imageLevels
                                              AND EUR_CRM_Status__c = 'Active']){
                String key = generateOPKey(objPromo);
                if(keyToObjectPromoMap.get(key) == null)
                    keyToObjectPromoMap.put(key, new Set<Id>());
                keyToObjectPromoMap.get(key).add(objPromo.id);                
            }       
        } 
        
        if(validAccountIds.size() >0){
            for(EUR_CRM_ObjPromo_Account_Mapping__c oAccount:[select id,EUR_CRM_ObjPromo__c,EUR_CRM_Account__c from EUR_CRM_ObjPromo_Account_Mapping__c where EUR_CRM_Account__c  in: validAccountIds
                                                             ]){
                if(accountObjectivesMap.get(oAccount.EUR_CRM_Account__c) == null)
                    accountObjectivesMap.put(oAccount.EUR_CRM_Account__c, new Set<Id>());
                accountObjectivesMap.get(oAccount.EUR_CRM_Account__c).add(oAccount.EUR_CRM_ObjPromo__c);
                opamap.put(''+oAccount.EUR_CRM_Account__c+oAccount.EUR_CRM_ObjPromo__c,oAccount.id);
            }       
        }
        
        Map<Id, EUR_CRM_ObjPromo__c> objAndPromoMap = new Map<Id, EUR_CRM_ObjPromo__c>();
        for(EUR_CRM_ObjPromo__c op : [Select Id, RecordtypeId FROM EUR_CRM_ObjPromo__c WHERE Id IN :opAndPromIds]){
          objAndPromoMap.put(op.Id, op);
        }
        
        for(EUR_CRM_Account__c euAccount : validAccounts ){
            Boolean accountActive = validStatus.contains(euAccount.EUR_CRM_Status_of_Customer__c);
            Boolean isOntrade = validOnTradeAccountIds.contains(euAccount.id);
            Set<Id> objPromos;
            String key = '';

            if(isOntrade){
                objPromos = new Set<Id>();
                String key1 = generateOPKey(euAccount);
                
                if(keyToObjectPromoMap.get(key1) != null)
                    objPromos.addAll(keyToObjectPromoMap.get(key1));
 
                String allRegionsKey =  euAccount.EUR_CRM_Group_Outlet_Type_Name__c  + euAccount.EUR_CRM_Image_Level_Name__c;
                //all Territory
                String allTerritoriesKey =  euAccount.EUR_CRM_Region__c + allRegionsKey;
                if(keyToObjectPromoMap.get(allRegionsKey) != null)
                    objPromos.addAll(keyToObjectPromoMap.get(allRegionsKey));
                if(keyToObjectPromoMap.get(allTerritoriesKey) != null)
                    objPromos.addAll(keyToObjectPromoMap.get(allTerritoriesKey));
                

            }else{
                key = euAccount.EUR_JB_Customer_Taxonomy__c;
                objPromos = keyToObjectPromoMap.get(key);
            } 
            if(Trigger.IsInsert && objPromos != null && euAccount.EUR_CRM_Status_of_Customer__c == ACTIVE){
                    /*for(Id objPromo : objPromos){
                      if(objAndPromoMap.containskey(objPromo)){
                        if(objAndPromoMap.get(objPromo).RecordtypeId != tastingOpId){
                          opAccountToinsert.add(new EUR_CRM_ObjPromo_Account_Mapping__c(
                            EUR_CRM_Account__c = euAccount.id,
                            EUR_CRM_ObjPromo__c = objPromo
                            ));
                        }
                      } else{
                        opAccountToinsert.add(new EUR_CRM_ObjPromo_Account_Mapping__c(
                        EUR_CRM_Account__c = euAccount.id,
                        EUR_CRM_ObjPromo__c = objPromo
                        ));
                      }
                    }*/
            }
            if(Trigger.IsUpdate){
                EUR_CRM_Account__c oldEuAccount = ((EUR_CRM_Account__c ) oldMap.get(euAccount.id));
                String oldKey = '';
                Set<Id> oldObjPromos;
                if(isOnTrade && (isChanged(euAccount,oldEuAccount,true) || 
                                (isChangedStatus(euAccount,oldEuAccount) && euAccount.EUR_CRM_Status_of_Customer__c == INACTIVE)))  {
                    oldKey = generateOPKey(oldEuAccount);
                    String allRegionsOldKey = oldEuAccount.EUR_CRM_Group_Outlet_Type_Name__c +  oldEuAccount.EUR_CRM_Image_Level_Name__c;
                    String allTerritoriesOldKey = oldEuAccount.EUR_CRM_Region__c + allRegionsOldKey;
                    
                    oldObjPromos = new Set<Id>();
                    if(keyToObjectPromoMap.get(oldKey) != null)
                        oldObjPromos.addAll(keyToObjectPromoMap.get(oldKey));
                        
                    if(keyToObjectPromoMap.get(allRegionsOldKey) != null)
                        oldObjPromos.addAll(keyToObjectPromoMap.get(allRegionsOldKey));

                    if(keyToObjectPromoMap.get(allTerritoriesOldKey) != null)
                        oldObjPromos.addAll(keyToObjectPromoMap.get(allTerritoriesOldKey));

                }else if(isChanged(euAccount,oldEuAccount,false)|| 
                        (isChangedStatus(euAccount,oldEuAccount) && euAccount.EUR_CRM_Status_of_Customer__c == INACTIVE)){
                     oldKey = oldEuAccount.EUR_JB_Customer_Taxonomy__c;
                     oldObjPromos = keyToObjectPromoMap.get(oldKey);
                }
                system.debug('++ old key: ' + oldkey + ' ' + objPromos);
                if(objPromos != null){
                    for(Id objPromo : objPromos){
                        system.debug('++ accountObjectivesMap.get(euAccount.id): ' + accountObjectivesMap.get(euAccount.id));
                        if(accountActive) {
                            if(accountObjectivesMap.get(euAccount.id) != null && accountObjectivesMap.get(euAccount.id).contains(objPromo)){
                                opAccountToupdate.add(new EUR_CRM_ObjPromo_Account_Mapping__c(id=(opamap.get(''+euAccount.id+objPromo))));
                                
                                system.debug('++ flag 1' + opamap.get(''+euAccount.id+objPromo));
                            }else {
                              if(objAndPromoMap.containskey(objPromo)){
                            if(objAndPromoMap.get(objPromo).RecordtypeId != tastingOpId){
                              opAccountToinsert.add(new EUR_CRM_ObjPromo_Account_Mapping__c(
                                EUR_CRM_Account__c = euAccount.id,
                                EUR_CRM_ObjPromo__c = objPromo,
                                    EUR_CRM_Is_Active__c = true
                                ));
                            }
                          } else{
                                  opAccountToinsert.add(new EUR_CRM_ObjPromo_Account_Mapping__c(
                                  EUR_CRM_Account__c = euAccount.id,
                                  EUR_CRM_ObjPromo__c = objPromo,
                                  EUR_CRM_Is_Active__c = true
                              ));}
                                system.debug('++ flag 2: ' + euAccount.id + ' ' +objPromo);
                            }
                        }   
                    }
                }
                system.debug('++ oldObjPromos ' +oldObjPromos );
                if(oldObjPromos != null){
                    for(Id objPromo : oldObjPromos){
                        if(!accountActive || 
                            isChanged(euAccount,oldEuAccount,isOntrade ))
                        opAccountTodelete.add(
                               new EUR_CRM_ObjPromo_Account_Mapping__c(id=(opamap.get(''+euAccount.id+objPromo))
                             ));

                    system.debug('!! opAccountid ' + opamap.get(''+euAccount.id+objPromo));
                    }
                }
                /*
                system.debug('++ oldObjPromos ' +oldObjPromos );
                if(oldObjPromos != null){
                    for(Id objPromo : oldObjPromos){
                    if((objPromos!= null && !objPromos.contains(objPromo) && !accountActive
                       ) || (euAccount.EUR_JB_Customer_Taxonomy__c == null
                       || 
                       (oldEuAccount.EUR_JB_Customer_Taxonomy__c != null && !accountActive) 
                        && !isOntrade))
                        opAccountTodelete.add(
                               new EUR_CRM_ObjPromo_Account_Mapping__c(id=(opamap.get(''+euAccount.id+objPromo))
                             ));
                    system.debug('!! opAccountid ' + opamap.get(''+euAccount.id+objPromo));
                    }
                }*/
            }
        }
        Savepoint sp = Database.setSavepoint();
        try{
            system.debug('inserting ' + opAccountToinsert );
            if(opAccountToinsert.size() > 0)
             insert opAccountToinsert;   
             //delete opAccountTodelete;
              List<EUR_CRM_ObjPromo_Account_Mapping__c> x = activateDeactivateOPAccount(opAccountToupdate,opAccountTodelete);
            system.debug('updating' + opAccountToupdate);
              if(x.size() > 0 )
                 update x;
        }catch(Exception e){
            Database.rollback(sp);
            system.debug('ERROR: ' + e); 
        }
    }
    
    public EUR_CRM_DE_AccountHandler(){
        super('EUR_CRM_DE_AccountHandler');
    }
    
    private final String ALL_REGIONS = 'All Regions';
    private final String ALL_TERRITORIES= 'All Territories';
    
    private String generateOPKey(EUR_CRM_ObjPromo__c objPromo){
        if(objPromo.EUR_CRM_Region__c == ALL_REGIONS)   
            return  objPromo.EUR_CRM_PROS_Group_Outlet__c  + objPromo.EUR_CRM_PROS_Image_Level__c;
        if(objPromo.EUR_CRM_Territory__c == ALL_TERRITORIES)    
            return objPromo.EUR_CRM_Region__c + objPromo.EUR_CRM_PROS_Group_Outlet__c  + objPromo.EUR_CRM_PROS_Image_Level__c;
        else        
            return objPromo.EUR_CRM_Region__c + objPromo.EUR_CRM_Territory__c + objPromo.EUR_CRM_PROS_Group_Outlet__c  + objPromo.EUR_CRM_PROS_Image_Level__c;
    }
    
    private String generateOPKey(EUR_CRM_Account__c euAccount){
        String region = euAccount.EUR_CRM_Region__c;
        String territory = territoryMap.get(euAccount.EUR_CRM_Territory__c) != null ? territoryMap.get(euAccount.EUR_CRM_Territory__c).name : '';
        String image =  euAccount.EUR_CRM_Image_Level_Name__c;
        String groupOutlet =  euAccount.EUR_CRM_Group_Outlet_Type_Name__c ;
        return  region + territory + groupOutlet + image;
    }
    
    private Boolean isChanged(EUR_CRM_Account__c euAccount, EUR_CRM_Account__c oldEuAccount, Boolean isOntrade){
        Boolean isChanged = false;
        if(isOntrade){
             isChanged =  ((oldEuAccount.EUR_CRM_Territory__c != euAccount.EUR_CRM_Territory__c) || 
                    (oldEuAccount.EUR_CRM_Image_Level_Name__c != euAccount.EUR_CRM_Image_Level_Name__c)  ||
                    (oldEuAccount.EUR_CRM_Group_Outlet_Type_Name__c  != euAccount.EUR_CRM_Group_Outlet_Type_Name__c) );
        }else{
             isChanged =  (oldEuAccount.EUR_JB_Customer_Taxonomy__c  != euAccount.EUR_JB_Customer_Taxonomy__c);
        }
        
         return isChanged || oldEuAccount.EUR_CRM_Status_of_Customer__c != euAccount.EUR_CRM_Status_of_Customer__c;
    }
    private Boolean isChangedStatus(EUR_CRM_Account__c euAccount, EUR_CRM_Account__c oldEuAccount){
        return (oldEuAccount.EUR_CRM_Status_of_Customer__c != euAccount.EUR_CRM_Status_of_Customer__c);
    }
    
    private List<EUR_CRM_ObjPromo_Account_Mapping__c> activateDeactivateOPAccount(List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountToinsert, List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountTodelete){
        Set<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountSet = new Set<EUR_CRM_ObjPromo_Account_Mapping__c>();
        Set<id> toActivate = new Set<Id>();
        system.debug('++ opAccountToinsert: ' + opAccountToinsert);
        system.debug('++ opAccountTodelete: ' + opAccountTodelete);
        for(EUR_CRM_ObjPromo_Account_Mapping__c opAccount : opAccountToinsert){
            opAccount.EUR_CRM_Is_Active__c = true;
            opAccountSet.add(opAccount);
            toActivate.add(opAccount.id);
        }
        for(EUR_CRM_ObjPromo_Account_Mapping__c opAccount : opAccountTodelete){
            if(!toActivate.contains(opAccount.id) && opAccount.id != null){
                opAccount.EUR_CRM_Is_Active__c = false;
                opAccountSet.add(opAccount);
            }
        }
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountList =  new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        opAccountList.addAll(opAccountSet);
        return opAccountList;
    }
}