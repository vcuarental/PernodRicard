public class EUR_CRM_FI_ObjectivePromoPageController{
    private EUR_CRM_ObjPromo__c objPromo;
    
    public List<EUR_CRM_ObjPromo_Target__c> objectiveVolumeTargets {get;set;} //deprecated
    public List<EUR_CRM_ObjPromo_Target__c> objectiveProductVolumeTargets {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> srVolumeTargets {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> objectiveCommitmentTarget {get;set;}
    public List<EUR_CRM_ObjPromo_Target__c> srCommitmentTargets {get;set;}
    
    public EUR_CRM_FI_ObjectivePromoPageController(ApexPages.StandardController stdController) { 
     objPromo = (EUR_CRM_ObjPromo__c) stdController.getRecord();
     initTargets();
    }
    public List<EUR_CRM_ObjPromo_Action__c> getActions(){
        
        List<EUR_CRM_ObjPromo_Action__c> actionList = new List<EUR_CRM_ObjPromo_Action__c>();
        actionList = [select id, 
        Name,
        EUR_CRM_Can_Reoccur__c,
        EUR_CRM_Entitle_Achievement__c,
        EUR_CRM_OP_Action_List_Template__c,
        EUR_CRM_Stage__c,
        EUR_CRM_OP_Sequence_Order__c,
        EUR_CRM_Stage_Sequence_Order__c
        from EUR_CRM_ObjPromo_Action__c
        where
        EUR_CRM_OP_Action_List_Template__c =: objPromo.EUR_CRM_OP_Action_List_Template__c
        order by EUR_CRM_OP_Sequence_Order__c ASC];
        
        return actionList;
    }
    void initTargets(){
        objectiveProductVolumeTargets = new List<EUR_CRM_ObjPromo_Target__c>(); 
        objectiveCommitmentTarget = new List<EUR_CRM_ObjPromo_Target__c>();
        srCommitmentTargets = new List<EUR_CRM_ObjPromo_Target__c>();
        srVolumeTargets = new List<EUR_CRM_ObjPromo_Target__c>(); 
        Map<Id, EUR_CRM_ObjPromo_Target__c> targets = new Map<Id, EUR_CRM_ObjPromo_Target__c>([select id,
                    EUR_CRM_BQS__c,
                    Name ,
                    EUR_CRM_BQS__r.name,
                    EUR_CRM_BQ__c,
                    EUR_CRM_Actual_Volume_Bottles__c,
                    EUR_CRM_Actual_Number_of_Commitments__c,
                    EUR_CRM_BQ__r.name,
                    EUR_CRM_SKU__c,
                    recordtype.developername,
                    EUR_CRM_Visit_Targets__c,
                    EUR_CRM_Is_Quota__c,
                    EUR_CRM_Target_Owner__c ,
                    EUR_CRM_Unit_of_Measure__c,
                    EUR_CRM_O_P_Target__c,
                    EUR_CRM_Distance_to_Goal__c,
                    EUR_CRM_Commitment_Target_Dist_to_Goals__c,
                    EUR_CRM_Grouping_Type__c,
                    EUR_CRM_SKU__r.name,EUR_CRM_Qty_Sell_in_Amount_Bottle__c   from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =: objPromo.Id
        ]); 
        Map<Id, Set<Id>> superMap = new Map<Id,Set<Id>>();
        for(EUR_CRM_ObjPromo_Target__c target : targets.values()){ 
             if(target.recordtype.developername == 'EUR_CRM_Objective_Commitment_Target')
                objectiveCommitmentTarget.add(target);
             if(target.recordtype.developername == 'EUR_CRM_SR_Commitment_Target')
                srCommitmentTargets.add(target);
             if(target.recordtype.developername == 'EUR_CRM_Objective_Volume_Target' || target.recordtype.developername == 'EUR_CRM_Objective_Product'){
                objectiveProductVolumeTargets.add(target);
                if(superMap.get(target.id) == null)
                    superMap.put(target.id, new Set<Id>());
             }if(target.recordtype.developername == 'EUR_CRM_SR_Volume_Target'){
                srVolumeTargets.add(target);
                if(superMap.get(target.EUR_CRM_O_P_Target__c) == null)
                    superMap.put(target.EUR_CRM_O_P_Target__c, new Set<Id>());
                superMap.get(target.EUR_CRM_O_P_Target__c).add(target.id);
             }
        }
        
        targetWraps = new List<TargetWrapper>();
        
        for(Id key : superMap.keySet()){            
            List<TargetWrapper> subTargets = new  List<TargetWrapper>();
            TargetWrapper targetWrapper =  new  TargetWrapper(targets.get(key),  subTargets);
            for(Id subKey : superMap.get(key)){
                subTargets.add(new TargetWrapper(targets.get(subKey),  null));            
            }
            targetWraps.add(targetWrapper);
        }       
    }
    
    
    public List<TargetWrapper> targetWraps {get;set;}
    public class TargetWrapper{
        public Boolean getHasChild(){
            return this.subTargets != null && this.subTargets.size() > 0;
        }
        public EUR_CRM_ObjPromo_Target__c target {get;set;}
        public List<TargetWrapper> subTargets {get;set;}
        public TargetWrapper(EUR_CRM_ObjPromo_Target__c target, List<TargetWrapper> subTargets) {
            this.target = target;
            this.subTargets = subTargets;
        }  
    }
     
}