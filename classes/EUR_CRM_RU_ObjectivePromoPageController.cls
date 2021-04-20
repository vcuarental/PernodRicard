public class EUR_CRM_RU_ObjectivePromoPageController {
    
    private EUR_CRM_ObjPromo__c objPromo;
    private String productLevel;
    public Boolean isOn {get; set;}
    
    public List<EUR_CRM_ObjPromo_Target__c> objectiveProductTargets {get; set;}
    Map<Id,Map<Id,Set<Id>>> superMap = new  Map<Id,Map<Id,Set<Id>>>();
    Map<Id,EUR_CRM_ObjPromo_Target__c> targets;
    
    String OBJECTIVE = 'Objective';
    // TODO: Change Sales Agency to Manager?
    String SALES_AGENCY = 'Sales Agency Managed';
    String REGIONAL = 'Regional';
    String RU_ON_PHASE_2 = 'EUR_RU_ON_Trade_Phase_2';
    String RU_LOYALTY_POSM = 'EUR_RU_Off_Trade_Loyalty_POSM_Placement';
    
    public EUR_CRM_RU_ObjectivePromoPageController(ApexPages.StandardController stdController) {
        objPromo = (EUR_CRM_ObjPromo__c) stdController.getRecord();
        system.debug('Current objPromo: '+objPromo);
        
        // Check whether it is an On Trade type 
        EUR_CRM_ObjPromo__c objPromo2 = [SELECT Id, RecordType.developername FROM EUR_CRM_ObjPromo__c WHERE Id =: objPromo.Id];
        isOn = ((objPromo2.recordtype.developername == 'EUR_RU_ON_Trade_Phase_1') || (objPromo2.recordtype.developername == 'EUR_RU_ON_Trade_Phase_2'))? true : false;
        
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
                      where EUR_CRM_OP_Action_List_Template__c =: objPromo.EUR_CRM_OP_Action_List_Template__c
                      order by EUR_CRM_OP_Sequence_Order__c ASC];
        
        return actionList;
    }
    
    public void initTargets(){
        this.objectiveProductTargets = new List<EUR_CRM_ObjPromo_Target__c>();
        targets = new Map<Id, EUR_CRM_ObjPromo_Target__c>([select id,
                                                           Name , EUR_CRM_Product_Level__c,
                                                           EUR_CRM_BQ__c, EUR_CRM_BQS__c, EUR_CRM_BQS__r.name,
                                                           EUR_CRM_Actual_Volume_Bottles__c,
                                                           EUR_CRM_Actual_Number_of_Commitments__c,
                                                           EUR_CRM_Target_Level__c,
                                                           EUR_CRM_BQ__r.name,
                                                           EUR_CRM_SKU__c,
                                                           EUR_CRM_SKU__r.name,
                                                           EUR_CRM_SKU__r.EUR_CRM_Article_no__c,
                                                           EUR_CRM_POS_Material__c,
                                                           EUR_CRM_POS_Material__r.Name,
                                                           EUR_CRM_Brand__c,
                                                           EUR_CRM_Brand__r.Name,
                                                           recordtype.developername,
                                                           EUR_CRM_Visit_Targets__c,
                                                           EUR_CRM_Is_Quota__c,
                                                           EUR_CRM_Target_Owner__c ,
                                                           EUR_CRM_Unit_of_Measure__c,
                                                           EUR_CRM_O_P_Target__c,
                                                           EUR_CRM_Distance_to_Goal__c,
                                                           EUR_CRM_Grouping_Type__c,
                                                           EUR_CRM_Percentage_Achieved__c,
                                                           EUR_CRM_Achieved__c,
                                                           EUR_CRM_Qty_Sell_in_Amount_Bottle__c,
                                                           EUR_CRM_Target_Quantity_Promo_Kits__c,
                                                           EUR_CRM_Actual_Quantity_Promo_Kits__c,
                                                           EUR_CRM_Distance_to_Goal_Promo_Kits__c,
                                                           EUR_CRM_Percentage_Achieved_Promo_Kits__c
                                                           from EUR_CRM_ObjPromo_Target__c
                                                           where EUR_CRM_ObjPromo__c =: objPromo.Id
                                                          ]);
        
        System.debug(targets.values());
        
        for(EUR_CRM_ObjPromo_Target__c target : targets.values()){
            if(productLevel == null) {
                productLevel = target.EUR_CRM_Product_Level__c;
            }
            if(target.EUR_CRM_Target_Level__c == OBJECTIVE) {
                objectiveProductTargets.add(target);
            }
            mapObject(target);
        }
        
        targetWraps = new List<TargetWrapper>();
        
        for(String objKey : superMap.keySet()){          
            List<TargetWrapper> regionalTargets = new List<TargetWrapper>();
            TargetWrapper targetWrap = new TargetWrapper(targets.get(objKey),regionalTargets);
            for(String regionalKey : superMap.get(objKey).keySet()){
                List<TargetWrapper> salesRepTargets = new List<TargetWrapper>();
                TargetWrapper regionalTargetWrap = new TargetWrapper(targets.get(regionalKey),salesRepTargets );
                
                for(Id srId : superMap.get(objKey).get(regionalKey)){
                    salesRepTargets.add(new TargetWrapper(targets.get(srId),null));
                }                
                regionalTargets.add(regionalTargetWrap);
            }
            targetWraps.add(targetWrap);
        }        
        
        System.debug(targetWraps);
    }
    
    public Object mapObject(EUR_CRM_ObjPromo_Target__c target) {
        if(target.EUR_CRM_Target_Level__c == SALES_AGENCY) {
            Set<Id> srTargets = (Set<Id>) mapObject(targets.get(target.EUR_CRM_O_P_Target__c));
            srTargets.add(target.Id);
            
            return null;
        } else if(target.EUR_CRM_Target_Level__c == OBJECTIVE) {
            if(superMap.get(target.id) == null) {
                superMap.put(target.id, new Map<Id, Set<Id>>());
            }
            
            return superMap.get(target.Id);
        } else if(target.EUR_CRM_Target_Level__c == REGIONAL) {
            Map<Id,Set<Id>> c = (Map<Id,Set<Id>>) mapObject(targets.get(target.EUR_CRM_O_P_Target__c));
            if(c.get(target.Id) == null) {
                c.put(target.Id, new Set<Id>());
            }
            
            return c.get(target.Id);
        }
        
        return null;
    }
    
    public String getOPStatus() {
        return objPromo.EUR_CRM_Status__c;
    }
    
    public Boolean getIsManageButtonRendered() {
        if(objPromo.recordType.Developername == 'EUR_RU_ON_Trade_Phase_1' && objPromo.EUR_CRM_Status__c == 'Active') {
            return false;
        }
        
        return true;
    }
    
    public Boolean getIsProductTableRendered() {
        if(objPromo.recordtype.Developername == RU_ON_PHASE_2 ||
           objPromo.recordtype.Developername == 'EUR_RU_Off_Trade_Loyalty_POSM_Placement') {
               return true;
           } 
        
        return false;
    }
    
    public Boolean getIsPhase2() {
        return objPromo.recordtype.developername == RU_ON_PHASE_2;
    }
    
    public Boolean getIsLoyaltyPOSM() {
        return objPromo.recordtype.developername == RU_LOYALTY_POSM;
    }
    
    public Boolean getIsPOSM() {
        return productLevel == 'EUR_CRM_POS_Material__c';
    }
    
    public Boolean getIsBrand() {
        return productLevel == 'EUR_CRM_Brand__c';
    }
    
    public Boolean getIsQuality() {
        return productLevel == 'EUR_CRM_Quality__c';
    }
    
    public Boolean getIsSKU() {
        return productLevel == 'EUR_CRM_SKU__c';
    }
    
    public Boolean getIsSize() {
        return productLevel == 'EUR_CRM_Size__c';
    }
    
    public PageReference publishOP() {
        /*EUR_CRM_ObjPromo__c currentObjectPromo = [select Id,EUR_CRM_Active_Start_Date__c,EUR_CRM_Status__c from EUR_CRM_ObjPromo__c where Id =:objPromo.Id];
        
        if (currentObjectPromo.EUR_CRM_Active_Start_Date__c > date.today()){
            objPromo.EUR_CRM_Status__c = 'Published';     
        }else{*/
            objPromo.EUR_CRM_Status__c = 'Active';
            /*List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccMappingList = [select Id,EUR_CRM_Is_Active__c,EUR_CRM_ObjPromo__c from EUR_CRM_ObjPromo_Account_Mapping__c where EUR_CRM_ObjPromo__c =:objPromo.Id];
            for (EUR_CRM_ObjPromo_Account_Mapping__c opAccMapping : opAccMappingList){
                opAccMapping.EUR_CRM_Is_Active__c = true;
                
            }
           update opAccMappingList;
        }*/
        update objPromo; 
        
        PageReference pageRef = new PageReference('/'+ ApexPages.currentPage().getParameters().get('id'));
        pageRef.setRedirect(true);
        return pageRef;
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