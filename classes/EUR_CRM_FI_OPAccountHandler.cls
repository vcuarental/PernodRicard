/**
 
    - 
*/
public class EUR_CRM_FI_OPAccountHandler  extends EUR_CRM_TriggerAbstract {
    
    private static final Set<String> allRecordTypes = new Set<String>{
      'EUR_FI_Direct_Off_Trade',
      'EUR_FI_Direct_On_Trade',
      'EUR_FI_Indirect_Off_Trade',
      'EUR_FI_Indirect_On_Trade' 
    };
    private final Set<String> offTradeFinlandRecordTypes = new Set<String>{
      'EUR_FI_Direct_Off_Trade',
      'EUR_FI_Indirect_Off_Trade'
    };
    
    private final Set<String> onTradeFinlandRecordTypes = new Set<String>{ 
      'EUR_FI_Indirect_On_Trade',
      'EUR_FI_Direct_On_Trade'
    };
    
    private final Set<String> validStatus = new Set<String>{ 
      'Active','Prospect','Potential Customer'
    }; 
     
    private final String ACTIVE = 'Active';
    private final String INACTIVE = 'Inactive';
    
    public static Set<String> TargetRecordSet {
        get{
            Set<String> TRt = new Set<String>();
            TRt.addAll(allRecordTypes);

            return TRt;
        }private set;
    }

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
        
        Map<Id,Set<Id>> accountObjectivesMap = new Map<Id,Set<Id>>();
        Map<String,Id> opAccountmap = new Map<String,Id>();
        //key = customer taxnomy or key = region + territory + groupoutlet  + image level
        Map<String,Set<Id>> keyToObjectPromoMap = new Map<String,Set<Id>>();
        
        Set<Id> customerTaxonomyIds = new Set<Id>();
        Set<String> groupOutlets = new Set<String>();
        Set<String> imageLevels = new Set<String>(); 
        
        for(EUR_CRM_Account__c euAccount : (List<EUR_CRM_Account__c>) sObjList){
            
            String accountRecordType = accountRecordTypesMap.get(euAccount.recordtypeid).developername;
            
            if(!allRecordTypes.contains(accountRecordType))
                continue;
            if(onTradeFinlandRecordTypes.contains(accountRecordType))
                validOnTradeAccountIds.add(euAccount.id);

            validAccounts.add(euAccount);
            validAccountIds.add(euAccount.id);

            if(euAccount.EUR_JB_Customer_Taxonomy__c!=null)
                customerTaxonomyIds.add(euAccount.EUR_JB_Customer_Taxonomy__c); 
            if(euAccount.EUR_CRM_Group_Outlet_Type_Name__c!=null && euAccount.EUR_CRM_Image_Level_Name__c !=null){
                groupOutlets.add(euAccount.EUR_CRM_Group_Outlet_Type_Name__c);
                imageLevels.add(euAccount.EUR_CRM_Image_Level_Name__c);
            }
            if(Trigger.IsUpdate){
                EUR_CRM_Account__c oldAccount = (EUR_CRM_Account__c ) oldMap.get(euAccount.id);
                if(oldAccount.EUR_JB_Customer_Taxonomy__c != euAccount.EUR_JB_Customer_Taxonomy__c )
                    customerTaxonomyIds.add(oldAccount.EUR_JB_Customer_Taxonomy__c); 
                if(euAccount.EUR_CRM_Group_Outlet_Type_Name__c!= oldAccount.EUR_CRM_Group_Outlet_Type_Name__c || 
                    euAccount.EUR_CRM_Image_Level_Name__c!= oldAccount.EUR_CRM_Image_Level_Name__c){
                    groupOutlets.add(oldAccount.EUR_CRM_Group_Outlet_Type_Name__c);
                    imageLevels.add(oldAccount.EUR_CRM_Image_Level_Name__c);
                }
            }
        }
        groupOutlets.remove(null);imageLevels.remove(null);customerTaxonomyIds.remove(null);
        
        if(customerTaxonomyIds.size() >0){
            for (EUR_CRM_OP_Customer_Taxonomy_Mapping__c opCustomerMapping : [SELECT Id, EUR_CRM_Customer_Taxonomy__c,
                                                                            EUR_CRM_ObjPromo__c 
                                                                            FROM EUR_CRM_OP_Customer_Taxonomy_Mapping__c
                                                                            WHERE EUR_CRM_Customer_Taxonomy__c IN:customerTaxonomyIds
                                                                            AND EUR_CRM_ObjPromo__r.EUR_CRM_Status__c = 'Active']){
                if(keyToObjectPromoMap.get(opCustomerMapping.EUR_CRM_Customer_Taxonomy__c) == null)
                    keyToObjectPromoMap.put(opCustomerMapping.EUR_CRM_Customer_Taxonomy__c, new Set<Id>());
                keyToObjectPromoMap.get(opCustomerMapping.EUR_CRM_Customer_Taxonomy__c).add(opCustomerMapping.EUR_CRM_ObjPromo__c);
            }
        }
        
        
        if(validOnTradeAccountIds.size() >0){
            for(EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c  opMapping:[select id,EUR_CRM_Group_Outlet_Type__c,EUR_CRM_Image_Level__c,EUR_CRM_ObjPromo__c
                from EUR_CRM_ObjPromo_to_PROS_Segment_Mapping__c  where           
                     EUR_CRM_Group_Outlet_Type__c in:groupOutlets 
                     AND EUR_CRM_Image_Level__c in:imageLevels
                     AND EUR_CRM_ObjPromo__r.EUR_CRM_Status__c = 'Active'
                     AND EUR_CRM_ObjPromo__r.RecordType.developername in ('EUR_FI_On_Trade_O_P','EUR_FI_Off_Trade_O_P')]){
                String key = opMapping.EUR_CRM_Image_Level__c + opMapping.EUR_CRM_Group_Outlet_Type__c; // generateOPKey(objPromo);
                if(keyToObjectPromoMap.get(key) == null)
                    keyToObjectPromoMap.put(key, new Set<Id>());
                keyToObjectPromoMap.get(key).add(opMapping.EUR_CRM_ObjPromo__c);                
            }       
        } 
        
        if(validAccountIds.size() >0){
            for(EUR_CRM_ObjPromo_Account_Mapping__c oAccount:[select id,EUR_CRM_ObjPromo__c,EUR_CRM_Account__c from EUR_CRM_ObjPromo_Account_Mapping__c where EUR_CRM_Account__c  in: validAccountIds
                 ]){
                if(accountObjectivesMap.get(oAccount.EUR_CRM_Account__c) == null)
                    accountObjectivesMap.put(oAccount.EUR_CRM_Account__c, new Set<Id>());
                accountObjectivesMap.get(oAccount.EUR_CRM_Account__c).add(oAccount.EUR_CRM_ObjPromo__c);
                opAccountmap.put(''+oAccount.EUR_CRM_Account__c+oAccount.EUR_CRM_ObjPromo__c,oAccount.id);
            }       
        }
            system.debug('@@ validAccountIds: ' + validAccountIds); 
            system.debug('@@ validOnTradeAccountIds: ' + validOnTradeAccountIds); 
            system.debug('@@ accountObjectivesMap: ' + opAccountmap); 
            system.debug('@@ keyToObjectPromoMap: ' + keyToObjectPromoMap); 
            system.debug('@@ customerTaxonomyIds: ' + customerTaxonomyIds); 
            system.debug('@@ groupOutlets: ' + groupOutlets); 
            system.debug('@@ imageLevels: ' + imageLevels);  
            system.debug('@@ opAccountmap: ' + opAccountmap); 

        for(EUR_CRM_Account__c euAccount : validAccounts ){
            Set<Id> objPromos = new Set<Id>();
            String custKey = '' + euAccount.EUR_JB_Customer_Taxonomy__c;
            String prosKey = '' + euAccount.EUR_CRM_Image_Level_Name__c + euAccount.EUR_CRM_Group_Outlet_Type_Name__c;
            String status = euAccount.EUR_CRM_Status__c;
         //    EUR_CRM_Status_of_Customer__c EUR_CRM_Customer_Status__c
            system.debug('@@ objPromos: ' + objPromos); 
            system.debug('@@ custKey: ' + custKey); 
            system.debug('@@ prosKey: ' + prosKey); 
            system.debug('@@ status: ' + status); 
            
            if(keyToObjectPromoMap.get(custKey) != null)
                objPromos.addAll(keyToObjectPromoMap.get(custKey));
            if(keyToObjectPromoMap.get(prosKey) != null)
                objPromos.addAll(keyToObjectPromoMap.get(prosKey));

            if(Trigger.IsInsert && objPromos.size() > 0 &&  validStatus.contains(status)){
                if(objPromos != null)
                for(Id objPromo : objPromos){
                    opAccountToinsert.add(new EUR_CRM_ObjPromo_Account_Mapping__c(
                        EUR_CRM_Account__c = euAccount.id,
                        EUR_CRM_ObjPromo__c = objPromo,
                        EUR_CRM_Is_Active__c = true
                        ));
                }
            }else if(Trigger.IsUpdate &&  validStatus.contains(status)){
                EUR_CRM_Account__c oldEuAccount = ((EUR_CRM_Account__c ) oldMap.get(euAccount.id));
                //get all old ops.
                //get all new ops.
                Set<Id> existingOPs = accountObjectivesMap.get(euAccount.id);
                system.debug('@@ existingOPs: ' + existingOPs);
                if(existingOPs != null)
                for(Id oldOP : existingOPs){
                    EUR_CRM_ObjPromo_Account_Mapping__c opa = new EUR_CRM_ObjPromo_Account_Mapping__c();
                    opa.id = opAccountmap.get(''+euAccount.id+oldOP);
                    opa.EUR_CRM_Is_Active__c = objPromos.contains(oldOP);
                    opAccountToupdate.add(opa);
                }
                if(objPromos != null)
                for(Id newOP : objPromos){
                    if(existingOPs == null || !existingOPs.contains(newOP)){                           
                        opAccountToinsert.add(new EUR_CRM_ObjPromo_Account_Mapping__c(
                            EUR_CRM_Account__c = euAccount.id,
                            EUR_CRM_ObjPromo__c = newOP,
                            EUR_CRM_Is_Active__c = true
                            ));
                    }
                }
            }else if(Trigger.IsUpdate &&  !validStatus.contains(status)){
                Set<Id> existingOPs = accountObjectivesMap.get(euAccount.id);
                if(existingOPs != null)
                for(Id oldOP : existingOPs){
                    EUR_CRM_ObjPromo_Account_Mapping__c opa = new EUR_CRM_ObjPromo_Account_Mapping__c();
                    opa.id = opAccountmap.get(''+euAccount.id+oldOP);
                    opa.EUR_CRM_Is_Active__c = false;
                    opAccountToupdate.add(opa);
                }
            }
        } 
        Savepoint sp = Database.setSavepoint();
        try{
            system.debug('@@ inserting ' + opAccountToinsert );
            system.debug('@@ updating ' + opAccountToupdate); 
            if(opAccountToinsert.size() > 0)
                insert opAccountToinsert;   
            if(opAccountToupdate.size() > 0) 
                update opAccountToupdate;   
        }catch(Exception e){
            Database.rollback(sp);
            system.debug('ERROR: ' + e); 
        }
    }
    
    public EUR_CRM_FI_OPAccountHandler(){
        super('EUR_CRM_FI_OPAccountHandler');
    } 
}