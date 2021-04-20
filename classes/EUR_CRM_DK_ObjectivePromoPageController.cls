public with sharing class EUR_CRM_DK_ObjectivePromoPageController {

    private EUR_CRM_ObjPromo__c objPromo;
    private String productLevel;
    
    public List<EUR_CRM_ObjPromo_Target__c> objectiveProductTargets {get; set;}
    Map<Id,Map<Id,Set<Id>>> superMap = new  Map<Id,Map<Id,Set<Id>>>();
    Map<Id,EUR_CRM_ObjPromo_Target__c> targets;
    
    public final String OP_OFF_EFFECTS_MANAGER = 'EUR_DK_Off_Trade_EM_Price_Promotion'; 
    public final String OP_OFF_DISTRIBUTION = 'EUR_DK_Off_Trade_Distribution_Drive';
    public final String OP_OFF_LEAFLET = 'EUR_DK_Off_Trade_Leaflet_Campaign';
    public final String OP_OFF_TASTING = 'EUR_DK_Off_Trade_Tasting_Campaign';
    String OBJECTIVE = 'Objective';
    String SALES_AGENCY = 'Sales Rep';
    String REGIONAL = 'Regional';
    
    public EUR_CRM_DK_ObjectivePromoPageController(ApexPages.StandardController stdController) {
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
                        where EUR_CRM_OP_Action_List_Template__c =: objPromo.EUR_CRM_OP_Action_List_Template__c
                        order by EUR_CRM_OP_Sequence_Order__c ASC];

        return actionList;
    }
    
    public void initTargets(){
        this.objectiveProductTargets = new List<EUR_CRM_ObjPromo_Target__c>();
        targets = new Map<Id, EUR_CRM_ObjPromo_Target__c>([select id,
                    Name , EUR_CRM_Product_Level__c,
                    EUR_CRM_BQS__c,
                    EUR_CRM_Actual_Volume_Bottles__c,
                    EUR_CRM_Actual_Number_of_Commitments__c,
                    EUR_CRM_Target_Level__c,
                    EUR_CRM_BQS__r.name,
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
                    EUR_CRM_Qty_Sell_in_Amount_Bottle__c
                  from EUR_CRM_ObjPromo_Target__c
                  where EUR_CRM_ObjPromo__c =: objPromo.Id
        ]);

        System.debug(targets.values());
        
        for(EUR_CRM_ObjPromo_Target__c target : targets.values()){
             if(productLevel == null) {
                //productLevel = target.EUR_CRM_Product_Level__c;
                if(target.EUR_CRM_SKU__c != null) {
                    productLevel = 'EUR_CRM_SKU__c';
                } else if(target.EUR_CRM_BQS__c != null) {
                    productLevel = 'EUR_CRM_Size__c';
                }
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
    
    public Boolean getIsTargetsRendered() {
        if(objPromo.recordType.DeveloperName == OP_OFF_EFFECTS_MANAGER ||
            objPromo.recordType.DeveloperName == OP_OFF_DISTRIBUTION ||
            objPromo.recordType.DeveloperName == OP_OFF_LEAFLET ||
            objPromo.recordType.DeveloperName == OP_OFF_TASTING) {

            return false;
        } else {
            return true;
        }
    }
    
    public Boolean getIsSize() {
        return productLevel == 'EUR_CRM_Size__c';
    }
    
    public Boolean getIsSKU() {
        return productLevel == 'EUR_CRM_SKU__c';
    }

    public PageReference publishOP() {
        // Update O/P to active
        objPromo.EUR_CRM_Status__c = 'Active';
        update objPromo;

        // Activate all O/P Account Mappings
        List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountMappings = [SELECT Id, EUR_CRM_Is_Active__c
                                                                        FROM EUR_CRM_ObjPromo_Account_Mapping__c
                                                                        WHERE EUR_CRM_ObjPromo__c = :objPromo.Id];

        System.debug(opAccountMappings);
        for(EUR_CRM_ObjPromo_Account_Mapping__c opAccountMapping : opAccountMappings) {
            opAccountMapping.EUR_CRM_Is_Active__c = true;
        }

        update opAccountMappings;
        
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