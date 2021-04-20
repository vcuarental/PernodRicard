/**
Batch job that runs every midnight to do the following
1. check for expired FI ON trade Visit Actions
    expired = visit action end date is less than today 
2. there are 2 types of visit actions
    a. Ad HOC visit
        uses the Product Toolkit to list the BQs
    b. Individual Account
        has individual visit action to list the BQs
3. If visit action is ad hoc.
    a. create a new visit action record with record type = EUR_CRM_FI_ON_Ad_Hoc_Activate_Toolkit_Follow_Up
    b. copy all the necessary fields from the visit action to the new
    c. deactivate the visit action record by setting the active flag to false
    d. create visit sub actions under the new visit action, with bq associated from the visit action product toolkit
4. if visit action is individual
    a. create a new visit action record with record type = FI_ON_Ad_Hoc_Create_Indiv_Account_OP_Follow_Up
    b. copy all the necessary fields from the visit action to the new
    c. deactivate the visit action record by setting the active flag to false
    d. copy the sub visit action from the visit action to the new visit action

Record Types
EUR_CRM_FI_ON_Ad_Hoc_Activate_Toolkit
EUR_CRM_FI_ON_Ad_Hoc_Activate_Toolkit_Follow_Up
FI_ON_Ad_Hoc_Create_Indiv_Account_OP
FI_ON_Ad_Hoc_Create_Indiv_Account_OP_Follow_Up


EUR_CRM_Visit_Action__c
EUR_CRM_Account__c
EUR_CRM_Status__c
EUR_CRM_Product_Toolkit__c
*/
global class EUR_CRM_FI_CreateVisitActionFollowUps implements Database.Batchable<sObject>{ 
     
    static List<String> adHocFields = new List<String>{
        'EUR_CRM_Visit_ID__c',  
        'EUR_CRM_Activation_End_Date__c',  
        'EUR_CRM_Account__c',
        'EUR_CRM_Stage__c',
        'EUR_CRM_Stage_Sequence_Order__c',
        'EUR_CRM_Activation_Start_Date__c',
        'EUR_CRM_Remarks__c',
        'OwnerId',
        'EUR_CRM_Product_Toolkit__c',
        'EUR_CRM_Active__c', 
        'EUR_CRM_End_Datetime__c',
        'RECORDTYPE.DEVELOPERNAME'};

    static List<String> indivFields = new List<String>{
        'EUR_CRM_Visit_ID__c', 
        'EUR_CRM_Account__c',
        'EUR_CRM_Stage__c',
        'EUR_CRM_Stage_Sequence_Order__c',
        'EUR_CRM_Activation_Start_Date__c',
        'EUR_CRM_Remarks__c',
        'OwnerId',
        'EUR_CRM_Indiv_Account_OP_Name__c',
        'EUR_CRM_Active__c',
        'EUR_CRM_Activation_End_Date__c',
        'EUR_CRM_End_Datetime__c',
        'RECORDTYPE.DEVELOPERNAME'};
    
    static Set<String> excludeFields = new Set<String>{
        'EUR_CRM_End_Datetime__c', 
        'EUR_CRM_Active__c',
        'EUR_CRM_Visit_ID__c',
        'RECORDTYPE.DEVELOPERNAME'};
    

    Map<String,String> visitActionRTMap = new Map<String,String>{
        'EUR_CRM_FI_ON_Ad_Hoc_Activate_Toolkit'=>'EUR_CRM_FI_ON_Ad_Hoc_Activate_Toolkit_Follow_Up'
    };

    static String VISIT_ACTION_ADHOC = 'EUR_CRM_FI_ON_Ad_Hoc_Activate_Toolkit';
    static String VISIT_ACTION_INDIV = 'FI_ON_Ad_Hoc_Create_Indiv_Account_OP';
    static String VISIT_ACTION_ADHOC_FOLLOW_UP = 'EUR_CRM_FI_ON_Ad_Hoc_Activate_Toolkit_Follow_Up';
    static String VISIT_ACTION_INDIV_FOLLOW_UP = 'FI_ON_Ad_Hoc_Create_Indiv_Account_OP_Follow_Up';
    static String VISIT_SUB_ACTION_ADHOC_FOLLOW_UP = 'EUR_CRM_FI_ON_Trade_Visit_Sub_Action_Adhoc_Activate_Toolkit_Follow_Up';
    static String VISIT_SUB_ACTION_INDIV_FOLLOW_UP = 'FI_ON_Trade_Visit_Sub_Action_Adhoc_Create_Indiv_Account_OP_Follow_Up_BQ_Vol';

    global static String generateQuery(){
        String q ='SELECT ID, NAME';
        Set<String> tempFields = new Set<String>();
        List<String> tempList = new List<String>();
        tempList.addAll(adHocFields);
        tempList.addAll(indivFields);
        for(String s : tempList){
            if(!tempFields.contains(s)){
                q += ' , ' + s + ' ';
                tempFields.add(s);
            }
        }

        q +=' FROM EUR_CRM_Visit_Action__c';
        q +=' WHERE RECORDTYPE.DEVELOPERNAME IN (\''+VISIT_ACTION_ADHOC+'\',\''+VISIT_ACTION_INDIV+'\')';
        q +=' AND EUR_CRM_Active__c = true';
        q +=' AND EUR_CRM_Activation_End_Date__c   < TODAY';
        system.debug('### query: ' + q);
        return q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(generateQuery());
    }
    
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        createFollowUps((List<EUR_CRM_Visit_Action__c> )scope);
    }
   
    global void finish(Database.BatchableContext BC){
    
    }
    
    global static void createFollowUps(List<EUR_CRM_Visit_Action__c> visitActions){

        Map<String, Id> visitActionRT = new Map<String, Id>();
        Map<String, Id> visitSubActionRT = new Map<String, Id>();
        for(RecordType rt :   [select id, developername,SObjectType  from RecordType where SObjectType in('EUR_CRM_Visit_Action__c','EUR_CRM_Visit_Sub_Action__c')]){
            if(rt.SObjectType == 'EUR_CRM_Visit_Action__c')
                visitActionRT.put(rt.developername,rt.id);
            if(rt.SObjectType == 'EUR_CRM_Visit_Sub_Action__c')
                visitSubActionRT.put(rt.developername,rt.id);
        }  
        system.debug('### visitActionRT: ' + visitActionRT);
        system.debug('### visitSubActionRT: ' + visitSubActionRT);

        List<EUR_CRM_Visit_Action__c> adHocVisits = new List<EUR_CRM_Visit_Action__c>();
        List<EUR_CRM_Visit_Action__c> indivVisits = new List<EUR_CRM_Visit_Action__c>();
        Set<Id> productToolkits = new Set<Id>();
        Set<Id> indivVisitIds = new Set<Id>();
        //segregate visit actions
        for(EUR_CRM_Visit_Action__c visitAction : visitActions){
            if(VISIT_ACTION_ADHOC == visitAction.recordType.developername){
                adHocVisits.add(visitAction);
                productToolkits.add(visitAction.EUR_CRM_Product_Toolkit__c);
            }
            else if(VISIT_ACTION_INDIV == visitAction.recordType.developername){
                indivVisits.add(visitAction);
                indivVisitIds.add(visitAction.id);
            }
        }
        //-- HANDLE AD HOC Visits.
        if(adHocVisits.size() > 0){
            system.debug('### adHocVisits: ' + adHocVisits);
            Map<Id, List<EUR_CRM_Product_Toolkit_Item__c>> prodToolkitMap = new 
            Map<Id, List<EUR_CRM_Product_Toolkit_Item__c>>();
            List<EUR_CRM_Visit_Action__c> newVisitActions = new List<EUR_CRM_Visit_Action__c>();
            List<EUR_CRM_Visit_Sub_Action__c> newVisitSubActions = new List<EUR_CRM_Visit_Sub_Action__c>();
            //query all prod toolkit item
            for(EUR_CRM_Product_Toolkit_Item__c item : [select id,EUR_CRM_Brand_Quality__c,EUR_CRM_Product_Toolkit__c from EUR_CRM_Product_Toolkit_Item__c where EUR_CRM_Product_Toolkit__c in:productToolkits ]){
                if(prodToolkitMap.get(item.EUR_CRM_Product_Toolkit__c) == null)
                    prodToolkitMap.put(item.EUR_CRM_Product_Toolkit__c, new List<EUR_CRM_Product_Toolkit_Item__c>());
                prodToolkitMap.get(item.EUR_CRM_Product_Toolkit__c).add(item );
            }
            system.debug('### prodToolkitMap: ' + prodToolkitMap);

            //create the visit action headers
            for(EUR_CRM_Visit_Action__c visitAction : adHocVisits){
                EUR_CRM_Visit_Action__c newVisitAction = new EUR_CRM_Visit_Action__c();
                newVisitAction = (EUR_CRM_Visit_Action__c) cloneObject(visitAction, newVisitAction, adHocFields, excludeFields, visitActionRT.get(VISIT_ACTION_ADHOC_FOLLOW_UP));
                newVisitActions.add(newVisitAction);
                visitAction.EUR_CRM_Active__c = false;
                newVisitAction.EUR_CRM_Active__c = true;
            }
            //insert new visit Actions
            insert newVisitActions;
            system.debug('### newVisitActions: ' + newVisitActions);
            //deactivate the visit actions
            update adHocVisits;
            system.debug('### adHocVisits: ' + adHocVisits);
            //create the sub visit actions
            for(EUR_CRM_Visit_Action__c visitAction : newVisitActions){
                if(prodToolkitMap.get(visitAction.EUR_CRM_Product_Toolkit__c) == null)
                    continue;
                for(EUR_CRM_Product_Toolkit_Item__c item : prodToolkitMap.get(visitAction.EUR_CRM_Product_Toolkit__c)){
                    EUR_CRM_Visit_Sub_Action__c newVisitSubAction = new EUR_CRM_Visit_Sub_Action__c(
                        EUR_CRM_Brand_Quality__c = item.EUR_CRM_Brand_Quality__c,
                        EUR_CRM_Visit_Action__c = visitAction.id,
                        recordTypeId = visitSubActionRT.get(VISIT_SUB_ACTION_ADHOC_FOLLOW_UP)
                    );
                    newVisitSubActions.add(newVisitSubAction);
                }
            }
            //insert the new subactions
            insert newVisitSubActions; 
            system.debug('### newVisitSubActions: ' + newVisitSubActions);
        }
        //-- HANDLE INDIV Visits.
        if(indivVisits.size() > 0){
            system.debug('### indivVisits: ' + indivVisits); 
            Map<Id, List<EUR_CRM_Visit_Sub_Action__c>> subActionMap = new 
            Map<Id, List<EUR_CRM_Visit_Sub_Action__c>>();
            Map<Id,EUR_CRM_Visit_Action__c> newVisitActions = new Map<Id,EUR_CRM_Visit_Action__c>();
            List<EUR_CRM_Visit_Sub_Action__c> newVisitSubActions = new List<EUR_CRM_Visit_Sub_Action__c>();
            //query all prod toolkit item
            for(EUR_CRM_Visit_Sub_Action__c visitSubAction : [select id,EUR_CRM_Brand_Quality__c,EUR_CRM_Display_Type__c,EUR_CRM_Visit_Action__c from EUR_CRM_Visit_Sub_Action__c where EUR_CRM_Visit_Action__c in:indivVisitIds ]){
                if(subActionMap.get(visitSubAction.EUR_CRM_Visit_Action__c) == null)
                    subActionMap.put(visitSubAction.EUR_CRM_Visit_Action__c, new List<EUR_CRM_Visit_Sub_Action__c>());
                subActionMap.get(visitSubAction.EUR_CRM_Visit_Action__c).add(visitSubAction);
            }
            system.debug('### subActionMap: ' + subActionMap);

            //create the visit action headers
            for(EUR_CRM_Visit_Action__c visitAction : indivVisits){
                EUR_CRM_Visit_Action__c newVisitAction = new EUR_CRM_Visit_Action__c();
                newVisitAction = (EUR_CRM_Visit_Action__c) cloneObject(visitAction, newVisitAction, indivFields, excludeFields, visitActionRT.get(VISIT_ACTION_INDIV_FOLLOW_UP));
                newVisitActions.put(visitAction.id, newVisitAction);
                visitAction.EUR_CRM_Active__c = false;
                newVisitAction.EUR_CRM_Active__c = true;
            }
            //insert new visit Actions
            insert newVisitActions.values();
            system.debug('### newVisitActions: ' + newVisitActions);
            //deactivate the visit actions
            update indivVisits;
            system.debug('### indivVisits: ' + indivVisits);
            //create the sub visit actions
            if(subActionMap != null && subActionMap.size() > 0) {
	            for(EUR_CRM_Visit_Action__c visitAction : indivVisits){
                    if(subActionMap.get(visitAction.Id) != null) {
                        for(EUR_CRM_Visit_Sub_Action__c item : subActionMap.get(visitAction.id)){
                            EUR_CRM_Visit_Sub_Action__c newVisitSubAction = new EUR_CRM_Visit_Sub_Action__c(
                                EUR_CRM_Brand_Quality__c = item.EUR_CRM_Brand_Quality__c,
                                EUR_CRM_Visit_Action__c = newVisitActions.get(visitAction.id).id,//retrieve the new visit action id.
                                recordTypeId = visitSubActionRT.get(VISIT_SUB_ACTION_INDIV_FOLLOW_UP)
                            );
                            newVisitSubActions.add(newVisitSubAction);
                        }
                    }
	            }
            }
            //insert the new subactions
            insert newVisitSubActions; 
            system.debug('### newVisitSubActions: ' + newVisitSubActions);
        }

    }

    global static sObject cloneObject(sObject src, sObject dest, List<String> fields, Set<String> excludeFieldSet, Id recordTypeId){
        for(String f : fields){
            if(!excludeFieldSet.contains(f)){
                dest.put(f, src.get(f));
            }
        }
        if(recordTypeId != null)
        dest.put('recordTypeId',recordTypeId);
        return dest;
    }
}