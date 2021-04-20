/*
*    Description : Apex controller class for ZA Objective Promo detail page
*
*    Version         Author            Date                Description
*    1.0             NA                NA                  Initial Draft
*    2.0             Sid               12/15/2015          Identify the ZA OP record type
*                                                          to render the products on detail page
*
*    3.0             Sid               12/22/2015          Code dev for 'Reactivate OP' feature
*    4.0             Kevin             17/03/2017          Code dev for 'Reactivate OP' feature

*/

public class EUR_CRM_ZA_ObjectivePromoPageController {
    
    private static final String STR_ZA_ONTRADE_RECTYPE = 'EUR_ZA_On_Trade_Promotion';    //Sid 2.0
    private static final String STR_ZA_OFFTRADE_RECTYPE = 'EUR_ZA_Off_Trade_Promotion';    //Sid 2.0
    private static final String STR_ZA_OP_STATUS_ENDED = 'Ended';    //Sid 3.0
    private static final String STR_ZA_OP_STATUS_DEACTIVATED = 'Deactivated';    //Kevin 4.0

    
    private EUR_CRM_ObjPromo__c objPromo;
    private Date dtEvalEndDate;
    
    public List<EUR_CRM_ObjPromo_Target__c> objectiveProductTargets {get; set;}
    public Boolean blnIsRecTypeOnTrade {get; set;}    //Sid 2.0
    public Boolean blnIsRecTypeOffTrade {get; set;}    //Sid 2.0
    
    public EUR_CRM_ZA_ObjectivePromoPageController(ApexPages.StandardController stdController) { 
        
        //Sid 2.0
        objPromo = (EUR_CRM_ObjPromo__c) stdController.getRecord();
        
        //Sid 3.0
        dtEvalEndDate = [select EUR_CRM_Evaluation_Period_End_Date__c from EUR_CRM_ObjPromo__c where Id =: objPromo.Id][0].EUR_CRM_Evaluation_Period_End_Date__c;

        String strRecTypeDevName = [select DeveloperName from RecordType where Id =: objPromo.recordTypeId][0].DeveloperName;
        blnIsRecTypeOnTrade = strRecTypeDevName.equalsIgnoreCase(STR_ZA_ONTRADE_RECTYPE) ? true : false;
        blnIsRecTypeOffTrade = strRecTypeDevName.equalsIgnoreCase(STR_ZA_OFFTRADE_RECTYPE) ? true : false;
     
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
    public void initTargets(){
        objectiveProductTargets = new List<EUR_CRM_ObjPromo_Target__c>();
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
                    EUR_CRM_Grouping_Type__c,
                    EUR_CRM_SKU__r.name,EUR_CRM_Qty_Sell_in_Amount_Bottle__c   from EUR_CRM_ObjPromo_Target__c where EUR_CRM_ObjPromo__c =: objPromo.Id
        ]); 
        Map<Id, Set<Id>> superMap = new Map<Id,Set<Id>>();
        for(EUR_CRM_ObjPromo_Target__c target : targets.values()){ 
            // TODO: Is this necessary? In the VF Page we don't display Targets anymore....
             if(target.recordType.developerName == 'EUR_CRM_Objective_Product') {
                 objectiveProductTargets.add(target);
                 if(superMap.get(target.id) == null) {
                    superMap.put(target.id, new Set<Id>());                     
                 }
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
    
    public String getOPStatus() {
        return objPromo.EUR_CRM_Status__c;
    }
    
    //Sid 3.0
    public Boolean getblnIsEvaluationElapsed() {

        return dtEvalEndDate < Date.today() && (objPromo.EUR_CRM_Status__c.equalsIgnoreCase(STR_ZA_OP_STATUS_ENDED) ? true : false || 
                                                 objPromo.EUR_CRM_Status__c.equalsIgnoreCase(STR_ZA_OP_STATUS_DEACTIVATED) ? true : false);//Kevin 4.0
        
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