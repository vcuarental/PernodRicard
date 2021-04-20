public with sharing class EUR_CRM_SE_ObjectivePromoPageController {

    private EUR_CRM_ObjPromo__c objPromo;
    private String productLevel;
    
    public List<EUR_CRM_ObjPromo_Target__c> objectiveProductTargets {get; set;}

    Map<Id,Map<Id,Set<Id>>> superMap = new  Map<Id,Map<Id,Set<Id>>>();
    Map<Id,EUR_CRM_ObjPromo_Target__c> targets;
    
    //OP Record 
    public final String OP_LISTING_CAMPAIGN  	= 'EUR_SE_Listing_Campaign';
    public final String OP_STAFF_COM       		= 'EUR_SE_Staff_Communication';
    public final String OP_VOL_CAM     			= 'EUR_SE_Volume_Campaign';
    public final String OP_VOL_TRIP  			= 'EUR_SE_Volume_Trip_Campaign_Bundle';
    public final String OP_VOL_CAM_SM  			= 'EUR_SE_Volume_Campaign_Slow_moving';
    public final String OP_EVENT  				= 'EUR_SE_Events';
    public final String OP_STAFF_TRAIN  		= 'EUR_SE_Staff_Training_Education';

    //Which Field to put the target
    private Map<String,String> opTargetFieldMap = new Map<String,String>
            {
                'EUR_SE_Listing_Campaign'           => 'EUR_CRM_Target_Quantity_Listing__c',
                'EUR_SE_Staff_Communication'        => 'EUR_CRM_Target_Quantity_People__c',
                'EUR_SE_Volume_Campaign'            => 'EUR_CRM_Qty_Sell_in_Amount_Bottle__c',
                'EUR_SE_Volume_Trip_Campaign_Bundle'=> 'EUR_SE_Objective_Product',
                'EUR_SE_Volume_Campaign_Slow_moving'=> 'EUR_CRM_Qty_Sell_in_Amount_Bottle__c',
                'EUR_SE_Events'                     => 'EUR_CRM_Target_Quantity_People__c',
                'EUR_SE_Staff_Training_Education'   => 'EUR_CRM_Target_Quantity_People__c'
            };

    //Which Field to put the actual
    private Map<String,String> opTargetFieldActualMap = new Map<String,String>
            {
                'EUR_SE_Listing_Campaign'           => 'EUR_CRM_Actual_Quantity_Listing__c',
                'EUR_SE_Staff_Communication'        => 'EUR_CRM_Actual_Quantity_People__c',
                'EUR_SE_Volume_Campaign'            => 'EUR_CRM_Actual_Volume_Bottles__c',
                'EUR_SE_Volume_Trip_Campaign_Bundle'=> 'EUR_CRM_Actual_Volume_Bottles__c',
                'EUR_SE_Volume_Campaign_Slow_moving'=> 'EUR_CRM_Actual_Volume_Bottles__c',
                'EUR_SE_Events'                     => 'EUR_CRM_Actual_Number_of_Commitments__c',
                'EUR_SE_Staff_Training_Education'   => 'EUR_CRM_Actual_Quantity_People__c'
            };

    //Convert Product Level to Field : Object / O/P Target.EUR_CRM_Product_Level__c to O/P Target.Field      
    private Map<String,String> productLvToField = new Map<String,String>
            {   'EUR_CRM_SKU__c'    => 'EUR_CRM_SKU__c',
                'EUR_CRM_Size__c'   => 'EUR_CRM_BQS__c',
                'EUR_CRM_Quality__c'=> 'EUR_CRM_BQ__c',
                'EUR_CRM_Brand__c'  => 'EUR_CRM_Brand__c'
            };


    public String TargetActualField		{get;set;}
	public String TargetQtyField		{get;set;}
	public String TargetProductField 	{get;set;}

    String OBJECTIVE = 'Objective';
    String SALES_AGENCY = 'Sales Rep';
    String REGIONAL = 'Regional';



    //Create Field API Name to Label Mapping
    /*public List<SFObjSelectTableDisplayField> displayFieldList { get; private set; }
    private void setFields(String fieldsStr) {
        List<String> displayFieldNameList = strToStrList(fieldsStr);
        this.displayFieldList = new List<SFObjSelectTableDisplayField>();
        sObject s = new EUR_CRM_ObjPromo_Target__c();

        Map<String, Schema.SObjectField> fieldMap = Schema.sObjectType.EUR_CRM_ObjPromo_Target__c.getDescribe().fields.getMap();
        for (String fieldName : displayFieldNameList) {
            SFObjSelectTableDisplayField df = new SFObjSelectTableDisplayField();
            Schema.SObjectField sObjField = fieldMap.get(fieldName);
            if (sObjField == null) {
                System.debug('Unknown field: ' + fieldName);
                continue;
            }
            Schema.DescribeFieldResult sObjFieldDescribe = sObjField.getDescribe();
            df.label = sObjFieldDescribe.getLabel();
            df.name = sObjFieldDescribe.getName();
            displayFieldList.add(df);
        }
        //this.queryFieldList = displayFieldNameList;
    }
    private List<String> strToStrList(String inputStr) { 
        return inputStr.split('\\,');
    } 
    public with sharing class SFObjSelectTableDisplayField {
        public String label { get; set; }
        public String name { get; set; }
    }*/
    
    public EUR_CRM_SE_ObjectivePromoPageController(ApexPages.StandardController stdController) {
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
                    EUR_CRM_Actual_Quantity_Listing__c,
                    EUR_CRM_Actual_Quantity_People__c,
                    EUR_CRM_Target_Level__c,
                    EUR_CRM_BQS__r.name,
                    EUR_CRM_BQ__r.name,
                    EUR_CRM_SKU__c,
                    EUR_CRM_SKU__r.name,
                    EUR_CRM_SKU__r.EUR_CRM_Article_no__c,
                    EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c,
                    EUR_CRM_SKU__r.EUR_CRM_Unit_Type__c,
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
                    EUR_CRM_Qty_Sell_in_Amount_Display__c,
                    EUR_CRM_Target_Quantity_Promo_Kits__c,
                    EUR_CRM_Target_Quantity_Spyders__c,
                    EUR_CRM_Target_Quantity_Listing__c,
                    EUR_CRM_Target_Quantity_People__c,
                    EUR_CRM_Account__c
                  from EUR_CRM_ObjPromo_Target__c
                  where EUR_CRM_ObjPromo__c =: objPromo.Id
        ]);

        System.debug('@@initTargets:' + targets.values());
        
        for(EUR_CRM_ObjPromo_Target__c target : targets.values()){
            System.debug(target);
            //System.debug(productLevel);
            if(productLevel == null) {
                if(target.EUR_CRM_SKU__c != null) {
                   productLevel = 'EUR_CRM_SKU__c';
                } else if(target.EUR_CRM_BQS__c != null) {
                   productLevel = 'EUR_CRM_Size__c';
                } else if(target.EUR_CRM_BQ__c != null) {
                   productLevel = 'EUR_CRM_Quality__c';
                } else if(target.EUR_CRM_Brand__c != null) {
                   productLevel = 'EUR_CRM_Brand__c';
                }
            }

            TargetProductField = productLvToField.get(productLevel);
            TargetQtyField = opTargetFieldMap.get(objPromo.recordType.DeveloperName);
            TargetActualField = opTargetFieldActualMap.get(objPromo.recordType.DeveloperName);

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
        if(objPromo.recordType.DeveloperName == OP_LISTING_CAMPAIGN ||
            objPromo.recordType.DeveloperName == OP_STAFF_COM ||
            objPromo.recordType.DeveloperName == OP_VOL_CAM ||
            objPromo.recordType.DeveloperName == OP_VOL_CAM_SM||
            objPromo.recordType.DeveloperName == OP_EVENT||
            objPromo.recordType.DeveloperName == OP_STAFF_TRAIN) {

            return true;
        } else {
            return false;
        }
    }

    public Boolean getIsProductSectionRendered() {
        If(objPromo.recordType.DeveloperName == OP_VOL_TRIP){
            return false;
        }
        return true;
    }

    public Boolean getIsVolumnTargetRendered(){
         if(objPromo.recordType.DeveloperName == OP_LISTING_CAMPAIGN ||
            objPromo.recordType.DeveloperName == OP_STAFF_COM ||
            objPromo.recordType.DeveloperName == OP_VOL_CAM ||
            objPromo.recordType.DeveloperName == OP_VOL_CAM_SM||
            objPromo.recordType.DeveloperName == OP_EVENT||
            objPromo.recordType.DeveloperName == OP_STAFF_TRAIN) {
            return true;
        } else {
            return false;
        }
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

            update opAccountMappings;
        }
        
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