public with sharing class EUR_CRM_BE_ObjectivePromoPageController {

    private EUR_CRM_ObjPromo__c objPromo;
    private String productLevel;
    
    public List<EUR_CRM_ObjPromo_Target__c> objectiveProductTargets {get; set;}
    Map<Id,Map<Id,Set<Id>>> superMap = new  Map<Id,Map<Id,Set<Id>>>();
    Map<Id,EUR_CRM_ObjPromo_Target__c> targets;
    
    public final String OP_OFF_SALES_DRIVE  = 'EUR_BE_Off_Trade_Sales_Drive';
    public final String OP_OFF_SPYDER       = 'EUR_BE_Off_Trade_Secondary_placement_Spyder_display';
    public final String OP_ON_PROMO_KIT     = 'EUR_BE_On_Trade_Promo_Kit_Activation';
    public final String OP_ON_SECOND_PLACE  = 'EUR_BE_On_Trade_Display_Placement_For_Specail_Cavist';


    String OBJECTIVE = 'Objective';
    String SALES_AGENCY = 'Sales Rep';
    String REGIONAL = 'Regional';
    
    public EUR_CRM_BE_ObjectivePromoPageController(ApexPages.StandardController stdController) {
        objPromo = (EUR_CRM_ObjPromo__c) stdController.getRecord();
        System.Debug('@@@Init:' + objPromo);
        initTargets();
    }
    
    
    public List<EUR_CRM_ObjPromo_Action__c> getActions(){
        System.Debug('@@@getActions:' + objPromo);

        if (objPromo != null && objPromo.EUR_CRM_OP_Action_List_Template__c == null)
        {
            objPromo.EUR_CRM_OP_Action_List_Template__c = [SELECT EUR_CRM_OP_Action_List_Template__c FROM EUR_CRM_ObjPromo__c Where Id =: objPromo.Id].EUR_CRM_OP_Action_List_Template__c;
        }

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
                    EUR_CRM_BQ__c,
                    EUR_CRM_Actual_Volume_Bottles__c,
                    EUR_CRM_Actual_Volume_Displays__c,
                    EUR_CRM_Actual_Quantity_Spyder__c,
                    EUR_CRM_Actual_Number_of_Commitments__c,
                    EUR_CRM_Actual_Quantity_Promo_Kits__c,
                    EUR_CRM_Target_Level__c,
                    EUR_CRM_BQS__r.name,
                    EUR_CRM_BQ__r.name,
                    EUR_CRM_SKU__c,
                    EUR_CRM_SKU__r.name,
                    EUR_CRM_SKU__r.EUR_CRM_Article_no__c,
                    EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c,
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
                    EUR_CRM_Distance_to_Goal_Displays__c,
                    EUR_CRM_Grouping_Type__c,
                    EUR_CRM_Percentage_Achieved__c,
                    EUR_CRM_Achieved__c,
                    EUR_CRM_Qty_Sell_in_Amount_Bottle__c,
                    EUR_CRM_Qty_Sell_in_Amount_Display__c,
                    EUR_CRM_Target_Quantity_Promo_Kits__c,
                    EUR_CRM_Target_Quantity_Spyders__c
                  from EUR_CRM_ObjPromo_Target__c
                  where EUR_CRM_ObjPromo__c =: objPromo.Id
        ]);

        System.debug('@@initTargets:' + targets.values());
        
        for(EUR_CRM_ObjPromo_Target__c target : targets.values()){
            System.debug(target);
            System.debug(productLevel);
            if(productLevel == null) {
                if(target.EUR_CRM_SKU__c != null) {
                   productLevel = 'EUR_CRM_SKU__c';
                } else if(target.EUR_CRM_BQS__c != null) {
                   productLevel = 'EUR_CRM_Size__c';
                } else if(target.EUR_CRM_BQ__c != null) {
                   productLevel = 'EUR_CRM_Quality__c';
                }
            }
            if(target.EUR_CRM_Target_Level__c == OBJECTIVE) {
                objectiveProductTargets.add(target);
            }

            if (target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c == null && (target.EUR_CRM_Qty_Sell_in_Amount_Display__c != null && target.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c != null)) {
                target.EUR_CRM_Qty_Sell_in_Amount_Bottle__c = target.EUR_CRM_Qty_Sell_in_Amount_Display__c * target.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c;
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
        setDefaults(targetWraps);
        System.debug(targetWraps);
    }
    
    public Object mapObject(EUR_CRM_ObjPromo_Target__c target) {
        //if(target.EUR_CRM_Target_Level__c == SALES_AGENCY) {
        //    Set<Id> srTargets = (Set<Id>) mapObject(targets.get(target.EUR_CRM_O_P_Target__c));
        //    srTargets.add(target.Id);
            
        //    return null;
        //} 
        if(target.EUR_CRM_Target_Level__c == OBJECTIVE) {
            if(superMap.get(target.id) == null) {
                superMap.put(target.id, new Map<Id, Set<Id>>());
            }
            
            return superMap.get(target.Id);
        } else if(target.EUR_CRM_Target_Level__c == SALES_AGENCY) {
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
        if(objPromo.recordType.DeveloperName == OP_OFF_SALES_DRIVE ||
            objPromo.recordType.DeveloperName == OP_OFF_SPYDER ||
            objPromo.recordType.DeveloperName == OP_ON_PROMO_KIT ||
            objPromo.recordType.DeveloperName == OP_ON_SECOND_PLACE) {

            return true;
        } else {
            return false;
        }
    }

    public Boolean getIsProductionSectionRendered() {
        if(objPromo.recordType.DeveloperName == OP_OFF_SALES_DRIVE ||
            objPromo.recordType.DeveloperName == OP_ON_SECOND_PLACE ) {

            return false;
        } else {
            return true;
        }
    }

    public Boolean getIsVolumnTargetRendered(){
        if(objPromo.recordType.DeveloperName == OP_OFF_SALES_DRIVE || objPromo.recordType.DeveloperName == OP_ON_PROMO_KIT ) {
            return true;
        } else {
            return false;
        }
    }

    public Boolean getIsSalesDrive(){
        return objPromo.recordType.DeveloperName == OP_OFF_SALES_DRIVE ;
    }

    public Boolean getIsPromoKit(){
        return objPromo.recordType.DeveloperName == OP_ON_PROMO_KIT;
    }

    public Boolean getIsSpyder(){
        return objPromo.recordType.DeveloperName == OP_OFF_SPYDER;
    }

    public Boolean getIsOnSecondPlace(){
        return objPromo.recordType.DeveloperName == OP_ON_SECOND_PLACE ;
    }
    
    public Boolean getIsSize() {
        return productLevel == 'EUR_CRM_Size__c';
    }
    
    public Boolean getIsSKU() {
        return productLevel == 'EUR_CRM_SKU__c';
    }

    public Boolean getIsQuality() {
        return productLevel == 'EUR_CRM_Quality__c';
    }



    public PageReference publishOP() {
        // Update O/P to active
        System.Debug('>>>Publish OP');
        objPromo.EUR_CRM_Active_Start_Date__c = [SELECT EUR_CRM_Active_Start_Date__c FROM EUR_CRM_ObjPromo__c WHERE id =: objPromo.Id Limit 1].EUR_CRM_Active_Start_Date__c ;

        if (objPromo.EUR_CRM_Active_Start_Date__c == Date.today()){
            objPromo.EUR_CRM_Status__c = 'Active';
        }else if (objPromo.EUR_CRM_Active_Start_Date__c > Date.today()) {
            objPromo.EUR_CRM_Status__c = 'Published';
        }
        
        update objPromo;

        if(objPromo.EUR_CRM_Status__c == 'Active'){
            // Activate all O/P Account Mappings
            List<EUR_CRM_ObjPromo_Account_Mapping__c> opAccountMappings = [SELECT Id, EUR_CRM_Is_Active__c
                                                                            FROM EUR_CRM_ObjPromo_Account_Mapping__c
                                                                            WHERE EUR_CRM_ObjPromo__c = :objPromo.Id];

            System.debug(opAccountMappings);
            for(EUR_CRM_ObjPromo_Account_Mapping__c opAccountMapping : opAccountMappings) {
                opAccountMapping.EUR_CRM_Is_Active__c = true;
            }

            try {
                update opAccountMappings;
            } catch(DMLException e) {
                if (e.getDmlType(0) == StatusCode.INSUFFICIENT_ACCESS_OR_READONLY) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_SaveError));
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getDmlMessage(0)));
                }
                return null;
            }
            
        }
        
        PageReference pageRef = new PageReference('/'+ ApexPages.currentPage().getParameters().get('id'));
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public List<TargetWrapper> targetWraps {get;set;}

    private void setDefaults(List<TargetWrapper> wrappList) {
        for (TargetWrapper wrapperParent : wrappList) {
            for (TargetWrapper wrapper : wrapperParent.subTargets) {
                if (wrapper.target.EUR_CRM_Actual_Volume_Displays__c == null) {
                    wrapper.target.EUR_CRM_Actual_Volume_Displays__c = 0;
                }
                if (wrapper.target.EUR_CRM_Actual_Volume_Bottles__c == null) {
                    wrapper.target.EUR_CRM_Actual_Volume_Bottles__c = 0;
                }
            }
        }
    }

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