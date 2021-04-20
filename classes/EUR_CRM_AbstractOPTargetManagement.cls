public class EUR_CRM_AbstractOPTargetManagement{    
    public static final String OBJ_VOL_TARGET = 'EUR_DE_Objective_Volume_Target'; //Level 1 - Top
    public static final String REG_VOL_TARGET = 'EUR_DE_Regional_Volume_Target'; // Level 2 - Mid
    public static final String SR_VOL_TARGET = 'EUR_DE_SR_Volume_Target'; // Level 3 - Low SR
    public static final String SALES_AGENCY_TARGET = 'EUR_DE_Sales_Agency_Managed_Target'; //
    public static  String RSM_OFF_TRADE = 'EUR_DE_Regional_Sales_Manager_Off_Trade_North_East';
    
    
    public static List<User> retrieveTargetOwnersSRLevel(Id customerTaxonomyId, Boolean test){
        Id regionalManager = null; 
        Set<Id> salesRepsId = new Set<ID>();
        Set<Id> validSalesRepsId = new Set<Id>();
        if(!test) {
            regionalManager= UserInfo.getUserId();
            salesRepsId = EUR_CRM_RoleUtils.getRoleSubordinateUsers(regionalManager);
        }else{
             regionalManager = '005D00000023mdBIAQ';            
             salesRepsId = EUR_CRM_RoleUtils.getRoleSubordinateUsers(RSM_OFF_TRADE);
        }       
        
        List<EUR_CRM_Account__c> euAccounts = [select id, EUR_CRM_Territory__r.EUR_CRM_Region__c, ownerId,owner.name from EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c =: customerTaxonomyId];
        
        for(EUR_CRM_Account__c euAccount : euAccounts ){            
            if(salesRepsId.contains(euAccount.ownerId))
                validSalesRepsId.add(euAccount.ownerId);
        }
        List<User> targetOwners = [select name, id from User where id in: validSalesRepsId];
        return targetOwners ;
    }    
    
    public static List<User> retrieveTargetOwnersRegionalLevel(Id customerTaxonomyId){
        List<EUR_CRM_Account__c> euAccounts = [select id, EUR_CRM_Territory__r.EUR_CRM_Region__c, ownerId,owner.name from EUR_CRM_Account__c where EUR_JB_Customer_Taxonomy__c =: customerTaxonomyId];
        Set<Id> regions= new Set<Id>();
        Set<Id> validSalesRepsId = new Set<ID>();    
            for(EUR_CRM_Account__c euAccount : euAccounts ){            
                regions.add(euAccount.EUR_CRM_Territory__r.EUR_CRM_Region__c);
            }
            for(EUR_CRM_Region__c region : [select ownerid from EUR_CRM_Region__c where id in:regions]){
                validSalesRepsId.add(region.ownerid);
            }
        List<User> targetOwners = [select name, id from User where id in: validSalesRepsId];
        return targetOwners;
    }
    
    /*
    
    */
    public static List<TargetWrap> retrieveTargets(
        Id objPromoId,
        EUR_CRM_ObjPromo_Target__c parentTarget,
        List<EUR_CRM_ObjPromo_Target__c > subTargets,
        Id parentRecordTypeId,
        Id subTargetRecordTypeId, 
        String targetField,
        List<User> targetOwners,
        Id regionalManager){
        
        Map<Id,EUR_CRM_ObjPromo_Target__c> parentTargets = null;
        
        if(regionalManager != null)
            parentTargets = new Map<Id,EUR_CRM_ObjPromo_Target__c>([select id,EUR_CRM_SKU__c,EUR_CRM_SKU__r.EUR_CRM_SKU_Code__c, EUR_CRM_SKU__r.name, EUR_CRM_ObjPromo__c,EUR_CRM_Qty_Sell_in_Amount_Bottle__c   from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =: objPromoId and recordtypeid =:parentRecordTypeId  ]);
        else
            parentTargets = new Map<Id,EUR_CRM_ObjPromo_Target__c>([select id,EUR_CRM_SKU__c,EUR_CRM_SKU__r.EUR_CRM_SKU_Code__c, EUR_CRM_SKU__r.name, EUR_CRM_ObjPromo__c,EUR_CRM_Qty_Sell_in_Amount_Bottle__c   from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =: 
                objPromoId and recordtypeid =:parentRecordTypeId and
                EUR_CRM_Target_Owner__c =: regionalManager ]);
 
        subTargets.addAll([select id,EUR_CRM_SKU__c,
                    EUR_CRM_O_P_Target__c,
                    EUR_CRM_Target_Owner__c,
                    EUR_CRM_Target_Owner__r.name,  
                    EUR_CRM_SKU__r.EUR_CRM_SKU_Code__c, EUR_CRM_SKU__r.name, EUR_CRM_ObjPromo__c,EUR_CRM_Qty_Sell_in_Amount_Bottle__c   
                    from EUR_CRM_ObjPromo_Target__c 
                    where EUR_CRM_ObjPromo__c =: objPromoId and 
                    EUR_CRM_O_P_Target__c in: parentTargets.keySet() and                   
                    recordtypeid =: subTargetRecordTypeId]);
        
        Map<Id, Set<Id>> existingTargetMap = new Map<Id, Set<Id>>();
        for(EUR_CRM_ObjPromo_Target__c  subTarget: subTargets ){
            if(existingTargetMap.get(subTarget.EUR_CRM_SKU__c) == null)
                existingTargetMap.put(subTarget.EUR_CRM_SKU__c, new Set<Id>());             
             existingTargetMap.get(subTarget.EUR_CRM_SKU__c).add(subTarget.EUR_CRM_Target_Owner__c);       
        }
        
        List<TargetWrap> targetWraps = new List<TargetWrap>();
        for(Id key : parentTargets.keySet()){
            EUR_CRM_ObjPromo_Target__c  target = parentTargets.get(key);
            List<EUR_CRM_ObjPromo_Target__c> subTargetsTemp = new List<EUR_CRM_ObjPromo_Target__c>();
            TargetWrap targetWrap = new TargetWrap(subTargetsTemp, target);
            Set<id> temp = existingTargetMap.get(target.EUR_CRM_SKU__c);
            for(User targetOwner: targetOwners){
                system.debug('Flag');
                if(temp != null && temp.contains(targetOwner.id)){ 
                    subTargetsTemp.add(retrieveTarget(target.EUR_CRM_SKU__c, targetOwner.id,subTargets,targetField )); 
                    system.debug('@@ Flag 1');
                }else{
                    system.debug('@@ Flag 2');
                    EUR_CRM_ObjPromo_Target__c subTarget = new EUR_CRM_ObjPromo_Target__c();
                    subTarget.EUR_CRM_ObjPromo__c = objPromoId; 
                    subTarget.put(targetField+ '__c',target.get(targetField+ '__c'));
                    subTarget.put(targetField+ '__r',target.get(targetField+ '__r'));  
                    subTarget.EUR_CRM_O_P_Target__c = target.id;
                    subTarget.recordtypeid = subTargetRecordTypeId; 
                    subTarget.EUR_CRM_Target_Owner__c = targetOwner.id;
                    subTarget.EUR_CRM_Target_Owner__r = targetOwner; 
                    subTargetsTemp.add(subTarget);
                    subTargets.add(subTarget);
               }
            }
            targetWraps.add(targetWrap);        
        }
        return targetWraps;
    }
    private static EUR_CRM_ObjPromo_Target__c retrieveTarget(Id skuId, Id srId, List<EUR_CRM_ObjPromo_Target__c > subTargets, String targetField ){
        
        EUR_CRM_ObjPromo_Target__c temp= null;
        for(EUR_CRM_ObjPromo_Target__c  srTarget : subTargets){
            if(srTarget.get(targetField + '__c') == skuId &&(srTarget.EUR_CRM_Target_Owner__c == srId)){
                temp = srTarget;
                break;
            }
        }    
        return temp;
    }
    public class TargetWrap{
       
        public EUR_CRM_ObjPromo_Target__c target{get;set;}
        public List<EUR_CRM_ObjPromo_Target__c> srTargets{get;set;}
        
        public TargetWrap(List<EUR_CRM_ObjPromo_Target__c> srTargets, EUR_CRM_ObjPromo_Target__c target){
            this.target= target;
            this.srTargets = srTargets;
        }
        public Boolean getVolumeBottleAchieved(){
            Decimal total = 0;
            if(srTargets != null && srTargets.size() >0)
            for(EUR_CRM_ObjPromo_Target__c sTarget: srTargets){
                Decimal stotal = sTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == null ? 0 :sTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c;
                total += stotal;
                
            }
            if(target != null && target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c > total)
                return true;
            return false;
        }
        public Boolean getVolumeDisplayAchieved(){
            Decimal total = 0;
            if(srTargets != null && srTargets.size() >0)
            for(EUR_CRM_ObjPromo_Target__c sTarget: srTargets){
                Decimal stotal = sTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == null ? 0 :sTarget.EUR_CRM_Qty_Sell_in_Amount_Bottle__c;
                total += stotal;
                
            }
            if(target != null && target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c > total)
                return true;
            return false;
        }
    }
}