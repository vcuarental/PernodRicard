/*

Applies to the following Vist Action Records Types
    a. EUR_FI_Confirm_Participation
    b. EUR_FI_Enter_Sell_In_Volume_Estimate
1. check visit action op visit target
    if(has visit target)
        check if visit action is successful with the following criteria:
            *what is the criteria of successful/positive account vist?
            success confirm participation 
2. check if the visit op is type 2, means has a volume target
    if(has volume target)
        get the volume and roll it up to the op target volume
3. mark the visit action as accrued.
*/
global class EUR_CRM_FI_AccrueAchievements implements Database.Batchable<sObject>{ 
     
    static List<String> visitFields = new List<String>{
        'EUR_CRM_Visit_ID__c',
        'EUR_CRM_Account__c',
        'EUR_CRM_Account__r.ownerid',
        'EUR_CRM_ObjPromo__c', 
        'EUR_CRM_ObjPromo__r.EUR_CRM_Status__c', 
        'EUR_CRM_Status__c',
        'EUR_CRM_ObjPromo_Target__c',
        'OwnerId', 
        'RECORDTYPE.DEVELOPERNAME'}; 

    static String VISIT_ACTION_CONFIRM_PARTICIPATION = 'EUR_FI_Confirm_Participation';
    static String VISIT_ACTION_ENTER_SELL_IN_VOLUME = 'EUR_FI_Enter_Sell_In_Volume_Estimate';
    static String VISIT_ACTION_FOLLOW_UP_TYPE_1 = 'EUR_FI_Follow_Up_Type_1';
    static String VISIT_ACTION_FOLLOW_UP_TYPE_2 = 'EUR_FI_Follow_Up_Type_2';
    static String VISIT_ACTION_PRESENTATION = 'EUR_FI_Presentation';
    static String VISIT_ACTION_ADDITIONAL_MATERIAL = 'EUR_FI_Record_Additional_Material';

    static String PARTICIPATING = 'Participating';
    static String ACTUALIZED= 'Actualized';
    static String EVALUATION_SUCCESSFUL = 'Evaluation: Successful';

    static Set<String> validRecordTypes = new Set<String>{
        'EUR_FI_Confirm_Participation',
        'EUR_FI_Enter_Sell_In_Volume_Estimate',
        'EUR_FI_Follow_Up_Type_2',
        'EUR_FI_Follow_Up_Type_1'//,
    //    'EUR_FI_Presentation',
    //    'EUR_FI_Record_Additional_Material'
    };
    global static String generateQuery(){ 
        String q ='SELECT ID, NAME'; 
        for(String s : visitFields){ 
            q += ' , ' + s + ' ';  
        }
        q +=' FROM EUR_CRM_Visit_Action__c';
        q +=' WHERE RECORDTYPE.DEVELOPERNAME IN   (\'EUR_FI_Confirm_Participation\',\'EUR_FI_Enter_Sell_In_Volume_Estimate\',\'EUR_FI_Follow_Up_Type_2\',\'EUR_FI_Follow_Up_Type_1\')'; 
        q +=' AND EUR_CRM_Is_Accrued__c = false';
        system.debug('### query: ' + q);
        return q;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(generateQuery());
    }
    
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        accrue((List<EUR_CRM_Visit_Action__c> )scope);
    }
   
    global void finish(Database.BatchableContext BC){
    
    }
    
    global static void accrue(List<EUR_CRM_Visit_Action__c> visitActions){
        if(visitActions == null || visitActions.size() == 0) {
            return;
        }

        List<EUR_CRM_Visit_Action__c> updateVisitActions = new List<EUR_CRM_Visit_Action__c>();
        Set<ID> visitAccountOwners = new Set<Id>();
        Set<ID> commitmentOPs = new Set<Id>(); //
        Set<ID> commitmentAccounts = new Set<Id>(); //
        Set<String> commitmentVisitCombo = new Set<String>(); //
        Set<ID> volumeVisitAccountOwners = new Set<Id>();
        Set<ID> volumeOPs = new Set<Id>(); //
        Set<ID> volumeVisits = new Set<Id>(); //
        Set<ID> followUpVisitOPs = new Set<Id>(); //
        Set<ID> followUpVisitAccounts = new Set<Id>(); //
        Set<String> followUpVisitCombo = new Set<String>();
        Map<Id, List<EUR_CRM_Visit_Action__c>> targetOwnerToVisitActionMap = new Map<Id, List<EUR_CRM_Visit_Action__c>>();

        //segregate
        for(EUR_CRM_Visit_Action__c visitAction : visitActions){
            if(VISIT_ACTION_CONFIRM_PARTICIPATION == visitAction.recordType.developername
                && visitAction.EUR_CRM_Status__c == PARTICIPATING
            ){             
                commitmentOPs.add(visitAction.EUR_CRM_ObjPromo__c);
                if(visitAction.EUR_CRM_Account__c != null){
                    if(targetOwnerToVisitActionMap.get(visitAction.EUR_CRM_Account__r.OwnerId) == null) {
                        targetOwnerToVisitActionMap.put(visitAction.EUR_CRM_Account__r.OwnerId, new List<EUR_CRM_Visit_Action__c>{visitAction});
                    } else {
                        targetOwnerToVisitActionMap.get(visitAction.EUR_CRM_Account__r.OwnerId).add(visitAction);
                    }
                    
                    visitAccountOwners.add(visitAction.EUR_CRM_Account__r.OwnerId);
                    
                    commitmentAccounts.add(visitAction.EUR_CRM_Account__c);
                    commitmentVisitCombo.add(''+visitAction.EUR_CRM_ObjPromo__c + visitAction.EUR_CRM_Account__c); 
                }
                visitAction.EUR_CRM_Is_Accrued__c = true;
                updateVisitActions.add(visitAction);
            }
            else if(VISIT_ACTION_ENTER_SELL_IN_VOLUME == visitAction.recordType.developername){ 
                volumeOPs.add(visitAction.EUR_CRM_ObjPromo__c);
                if(visitAction.EUR_CRM_Account__c != null)
                    volumeVisitAccountOwners.add(visitAction.EUR_CRM_Account__r.OwnerId);
                visitAction.EUR_CRM_Is_Accrued__c = true; 
                volumeVisits.add(visitAction.id);
                updateVisitActions.add(visitAction);
            } 
            else if( VISIT_ACTION_FOLLOW_UP_TYPE_1 == visitAction.recordType.developername ||
                VISIT_ACTION_FOLLOW_UP_TYPE_2 == visitAction.recordType.developername  ){
                if(visitAction.EUR_CRM_ObjPromo__c != null && visitAction.EUR_CRM_ObjPromo__r.EUR_CRM_Status__c
                    == 'Under Evaluation' && visitAction.EUR_CRM_Account__c != null && 
                visitAction.EUR_CRM_Status__c == EVALUATION_SUCCESSFUL){
                    visitAction.EUR_CRM_Is_Accrued__c = true;
                    followUpVisitOPs.add(visitAction.EUR_CRM_ObjPromo__c);
                    followUpVisitAccounts.add(visitAction.EUR_CRM_Account__c);
                    updateVisitActions.add(visitAction);
                    followUpVisitCombo.add(''+visitAction.EUR_CRM_ObjPromo__c + visitAction.EUR_CRM_Account__c);                 
                }
            } 
        }
        //for commitment visits
        Set<EUR_CRM_ObjPromo_Target__c> updateOPTargets = new Set<EUR_CRM_ObjPromo_Target__c>();
        Map<Id,EUR_CRM_Visit_Sub_Action__c > updateVisitSubActions = new Map<Id,EUR_CRM_Visit_Sub_Action__c >();
        Map<Id,EUR_CRM_ObjPromo__c> updateOPs = new Map<Id,EUR_CRM_ObjPromo__c>();  
        Set<Id> commitmentTargets = new Set<Id>();
        
        system.debug('### visitAccountOwners: ' + visitAccountOwners);
        system.debug('### commitmentOPs: ' + commitmentOPs);

        Set<Id> deactivatedSRs = new Set<Id>();
        Set<Id> deactivatedSROP = new Set<Id>();
        Set<Id> deactivatedOPS = new Set<Id>();
        Set<String> deactivatedSROPCombo = new Set<String>();

        // Accrue Commitment visits
        if(visitAccountOwners.size() > 0 && commitmentOPs.size() > 0){
            Map<Id,EUR_CRM_ObjPromo_Target__c> opParentTargetMap = new Map<Id,EUR_CRM_ObjPromo_Target__c>(); // Map of Objective Level Targets
            Map<Id, EUR_CRM_ObjPromo_Target__c> targets = new Map<Id, EUR_CRM_ObjPromo_Target__c>([SELECT id,EUR_CRM_Is_Quota__c,EUR_CRM_O_P_Target__c,EUR_CRM_Target_Owner__c, EUR_CRM_Visit_Targets__c, EUR_CRM_ObjPromo__c, EUR_CRM_Actual_Number_of_Commitments__c
                                                        FROM EUR_CRM_ObjPromo_Target__c 
										                WHERE  EUR_CRM_Target_Owner__c IN :visitAccountOwners 
										                AND EUR_CRM_ObjPromo__c IN :commitmentOPs
										                AND recordType.developername ='EUR_CRM_SR_Commitment_Target']);
            
            Map<Id, List<EUR_CRM_ObjPromo_Target__c>> targetOwnerToOPTargetMap = new Map<Id, List<EUR_CRM_ObjPromo_Target__c>>();
            Set<Id> parentOPs = new Set<Id>();
            
            // Maps Target Owner to Target
            // And populate a set of Parent OP (Objective Level) Id
            for(EUR_CRM_ObjPromo_Target__c target: targets.values()) {
                if(targetOwnerToOPTargetMap.get(target.EUR_CRM_Target_Owner__c) == null) {
                    targetOwnerToOPTargetMap.put(target.EUR_CRM_Target_Owner__c, new List<EUR_CRM_ObjPromo_Target__c>{target});
                } else {
                    targetOwnerToOPTargetMap.get(target.EUR_CRM_Target_Owner__c).add(target);
                }
                parentOps.add(target.EUR_CRM_O_P_Target__c);
            }
            
            System.debug(targets);
            System.debug(targetOwnerToOPTargetMap);
            
            opParentTargetMap = new Map<Id,EUR_CRM_ObjPromo_Target__c>([select id,EUR_CRM_ObjPromo__c,EUR_CRM_Visit_Targets__c,EUR_CRM_Is_Quota__c, EUR_CRM_Actual_Number_of_Commitments__c from EUR_CRM_ObjPromo_Target__c where id in:parentOps]);
            
            System.debug(targetOwnerToVisitActionMap);
            System.debug(parentOps);
            System.debug(opParentTargetMap);
            
            for(EUR_CRM_ObjPromo_Target__c opTarget: targets.values()){
                if(targetOwnerToVisitActionMap.get(opTarget.EUR_CRM_Target_Owner__c) != null) {
                    for(EUR_CRM_Visit_Action__c visitAction: targetOwnerToVisitActionMap.get(opTarget.EUR_CRM_Target_Owner__c)) {
                        
                        // Barrier to prevent visit actions from other OP to be accrued
                        if(opTarget.EUR_CRM_ObjPromo__c != visitAction.EUR_CRM_ObjPromo__c) {
                            continue;
                        }
                        
                        // Determine the OP Target to accrue
                        // Based on the current visit action (visitAction) and OP Target (opTarget) in the loop
                        Id visitActionOwnerId = visitAction.EUR_CRM_Account__r.OwnerId;
                        EUR_CRM_ObjPromo_Target__c target;
                        for(EUR_CRM_ObjPromo_Target__c visitActionOPTarget: targetOwnerToOPTargetMap.get(visitActionOwnerId)) {
                            if(visitActionOPTarget.EUR_CRM_ObjPromo__c == opTarget.EUR_CRM_ObjPromo__c) {
                                target = visitActionOPTarget;
                            }
                        }
                        
                        System.debug(target);
                        
                        // Accrue the visit, adding 1 to the running # commitments
	                    Decimal visitNumber = target.EUR_CRM_Actual_Number_of_Commitments__c ;
	                    visitNumber = visitNumber == null ? 1 : (visitNumber + 1);
	                    target.EUR_CRM_Actual_Number_of_Commitments__c = visitNumber;
	                    updateOPTargets.add(target);
	                    
	                    system.debug('### visitNumber: ' + visitNumber);
	                    
	                    // Additional logic to determine whether OP should be deactivated or not
	                    if(visitNumber  >= target.EUR_CRM_Visit_Targets__c &&
	                            target.EUR_CRM_Is_Quota__c){
	                        deactivatedSROPCombo.add('' + target.EUR_CRM_Target_Owner__c + target.EUR_CRM_ObjPromo__c);
	                        deactivatedSRs.add(target.EUR_CRM_Target_Owner__c);
	                        deactivatedSROP.add(target.EUR_CRM_ObjPromo__c);
	                    }
	                    
	                    EUR_CRM_ObjPromo_Target__c parentTarget = opParentTargetMap.get(target.EUR_CRM_O_P_Target__c);
	                        if(parentTarget != null){     
	                             Decimal currentParentQty = parentTarget.EUR_CRM_Actual_Number_of_Commitments__c == null ? 0 : parentTarget.EUR_CRM_Actual_Number_of_Commitments__c; 
	                             parentTarget.EUR_CRM_Actual_Number_of_Commitments__c = currentParentQty + 1;
	                             if(parentTarget.EUR_CRM_Actual_Number_of_Commitments__c >= parentTarget.EUR_CRM_Visit_Targets__c 
	                                && parentTarget.EUR_CRM_Is_Quota__c){
	                                updateOPs.put(parentTarget.EUR_CRM_ObjPromo__c, new EUR_CRM_ObjPromo__c(id =parentTarget.EUR_CRM_ObjPromo__c, EUR_CRM_Status__c = 'Under Evaluation' ));
	                                deactivatedOPS.add(parentTarget.EUR_CRM_ObjPromo__c);
	                         }
	                    }
                    }                 
                }
            }
     
            if(opParentTargetMap != null && opParentTargetMap.values() != null && opParentTargetMap.values().size() > 0) {
                updateOPTargets.addAll(opParentTargetMap.values());
            }
        } 
        system.debug('### volumeVisits: ' + volumeVisits);
        system.debug('### volumeVisitAccountOwners: ' + volumeVisitAccountOwners);
        system.debug('### volumeOPs: ' + volumeOPs);
        system.debug('### deactivatedSRs: ' + deactivatedSRs);
        system.debug('### deactivatedSROP: ' + deactivatedSROP);
        system.debug('### deactivatedOPS: ' + deactivatedOPS);
        system.debug('### deactivatedSROPCombo: ' + deactivatedSROPCombo);

        if(volumeVisits.size() > 0){
            //String KEY = ObjPromo + targetOwner + prductId
            Map<String,EUR_CRM_ObjPromo_Target__c> opTargetMap = new Map<String,EUR_CRM_ObjPromo_Target__c>();
            Map<Id,EUR_CRM_ObjPromo_Target__c> opParentTargetMap = new Map<Id,EUR_CRM_ObjPromo_Target__c>();
            Set<Id> parentOps = new Set<ID>();
            for(EUR_CRM_ObjPromo_Target__c target: [select id,EUR_CRM_O_P_Target__c,EUR_CRM_Visit_Targets__c, EUR_CRM_BQS__c,EUR_CRM_BQ__c,EUR_CRM_SKU__c,EUR_CRM_Actual_Volume_Bottles__c,
                EUR_CRM_ObjPromo__c,EUR_CRM_Target_Owner__c from EUR_CRM_ObjPromo_Target__c 
                where  EUR_CRM_Target_Owner__c in:volumeVisitAccountOwners AND EUR_CRM_ObjPromo__c in:volumeOPs
                AND recordType.developername ='EUR_CRM_SR_Volume_Target']){
                String key = '' + target.EUR_CRM_ObjPromo__c + target.EUR_CRM_Target_Owner__c;
                String prodkey = '';
                if(target.EUR_CRM_BQ__c != null)
                    prodkey = target.EUR_CRM_BQ__c;
                else if(target.EUR_CRM_BQS__c != null)
                    prodkey = target.EUR_CRM_BQS__c;
                else if(target.EUR_CRM_SKU__c != null)
                    prodkey = target.EUR_CRM_SKU__c;
                key +=prodkey;
                system.debug('### target key: ' + key);
                opTargetMap.put(key, target);
                updateOPTargets.add(target);

                parentOps.add(target.EUR_CRM_O_P_Target__c);
            }
            //opParentTargetMap = new Map<Id,EUR_CRM_ObjPromo_Target__c>([select id,EUR_CRM_ObjPromo__c,EUR_CRM_Visit_Targets__c,EUR_CRM_Actual_Volume_Bottles__c, EUR_CRM_Is_Quota__c, EUR_CRM_Actual_Number_of_Commitments__c 
            //                                                            from EUR_CRM_ObjPromo_Target__c
            //                                                            where id
            //                                                            in:parentOps]);
            system.debug('### opTargetMap: ' + opTargetMap);
            for(EUR_CRM_Visit_Sub_Action__c subAction : [select EUR_CRM_Brand_Quality__c, EUR_CRM_Brand_Quality_Size__c , EUR_CRM_SKU__c, 
                    EUR_CRM_Visit_Action__r.EUR_CRM_Account__r.OwnerId,
                     EUR_CRM_Visit_Action__r.EUR_CRM_ObjPromo__c,
                     EUR_CRM_Number_of_Bottles__c  
                    from EUR_CRM_Visit_Sub_Action__c where
               EUR_CRM_Visit_Action__c in:volumeVisits ]){
                String key = '' + subAction.EUR_CRM_Visit_Action__r.EUR_CRM_ObjPromo__c + subAction.EUR_CRM_Visit_Action__r.EUR_CRM_Account__r.OwnerId;
                String prodkey = '';
                if(subAction.EUR_CRM_Brand_Quality__c != null)
                    prodkey = subAction.EUR_CRM_Brand_Quality__c;
                else if(subAction.EUR_CRM_Brand_Quality_Size__c != null)
                    prodkey = subAction.EUR_CRM_Brand_Quality_Size__c;
                else if(subAction.EUR_CRM_SKU__c!= null)
                    prodkey = subAction.EUR_CRM_SKU__c;
                key +=prodkey;
                system.debug('### subAction key: ' + key);
                EUR_CRM_ObjPromo_Target__c target = opTargetMap.get(key);
                subAction.EUR_CRM_Is_Accrued__c = true;
                updateVisitSubActions.put(subAction.id,subAction);
                
                if(target != null && subAction.EUR_CRM_Number_of_Bottles__c != null && subAction.EUR_CRM_Number_of_Bottles__c > 0){
                    Decimal currentQty = target.EUR_CRM_Actual_Volume_Bottles__c == null ? 0 : target.EUR_CRM_Actual_Volume_Bottles__c; 
                    target.EUR_CRM_Actual_Volume_Bottles__c = currentQty + subAction.EUR_CRM_Number_of_Bottles__c;
                    //EUR_CRM_ObjPromo_Target__c parentTarget = opParentTargetMap.get(target.EUR_CRM_O_P_Target__c);
                    //System.debug('### parentTarget: '+parentTarget);
                    //if(parentTarget != null){     
                   //     Decimal currentParentQty = parentTarget.EUR_CRM_Actual_Volume_Bottles__c == null ? 0 : parentTarget.EUR_CRM_Actual_Volume_Bottles__c; 
                   //     parentTarget.EUR_CRM_Actual_Volume_Bottles__c = currentParentQty + subAction.EUR_CRM_Number_of_Bottles__c;
                        //if((parentTarget.EUR_CRM_Actual_Number_of_Commitments__c == parentTarget.EUR_CRM_Visit_Targets__c) && parentTarget.EUR_CRM_Is_Quota__c == true){
                        //    updateOPs.put(parentTarget.EUR_CRM_ObjPromo__c, new EUR_CRM_ObjPromo__c(id=parentTarget.EUR_CRM_ObjPromo__c, EUR_CRM_Status__c = 'Under Evaluation'));
                        //}
                   //}
                } 
            }
            //if(opParentTargetMap != null && opParentTargetMap.values() != null && opParentTargetMap.values().size() > 0)
            //    updateOPTargets.addAll(opParentTargetMap.values());
            //select all visit sub actions
            //select all concernt op targets
        }
        List<EUR_CRM_ObjPromo_Account_Mapping__c> updateOPACcountMapping = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();
        
        /*
            handle OP Account Mapping evaluation period.
            
        */  

        Set<Id> opTemp = new Set<Id>();
        Set<Id> accountTemp = new Set<Id>();

        opTemp.addAll(followUpVisitOPs);
        opTemp.addAll(commitmentOPs);
        accountTemp.addAll(followUpVisitAccounts);
        accountTemp.addAll(commitmentAccounts);

        if(opTemp.size() > 0 && accountTemp.size() > 0){
            
            for(EUR_CRM_ObjPromo_Account_Mapping__c m: [select id,EUR_CRM_Account__c,EUR_CRM_ObjPromo__c
                    from EUR_CRM_ObjPromo_Account_Mapping__c 
                    where EUR_CRM_ObjPromo__c in:opTemp and EUR_CRM_Account__c in:accountTemp]){
                String combo = ''+m.EUR_CRM_ObjPromo__c+m.EUR_CRM_Account__c;
                Boolean flag = false;
                if(followUpVisitCombo.contains(combo)){
                    m.EUR_CRM_Evaluation_Required__c = false; 
                    flag =true;
                }
                
                if(commitmentVisitCombo.contains(combo)){
                    m.EUR_CRM_Evaluation_Required__c = true;
                    flag =true;
                }
                if(flag)
                    updateOPACcountMapping.add(m);
            }

        }

        //handler the op account mapping deactivation.

       // deactivatedSRs;
        //deactivatedSROP ;
       // deactivatedOPS ;
       // deactivatedSROPCombo;
        List<EUR_CRM_ObjPromo_Account_Mapping__c> deactivateOPAccountMappings = new List<EUR_CRM_ObjPromo_Account_Mapping__c>();

        List<EUR_CRM_ObjPromo_Account_Mapping__c> opmappings = [select id from EUR_CRM_ObjPromo_Account_Mapping__c where EUR_CRM_ObjPromo__c in:deactivatedOPS and EUR_CRM_Is_Active__c = true];
        if(opmappings != null && opmappings.size() > 0){
            deactivateOPAccountMappings.addAll(opmappings);
        }

        for(EUR_CRM_ObjPromo_Account_Mapping__c opm: [select id,EUR_CRM_Account__r.ownerid, EUR_CRM_ObjPromo__c from EUR_CRM_ObjPromo_Account_Mapping__c where EUR_CRM_Account__r.ownerid in:deactivatedSRs and EUR_CRM_ObjPromo__c in:deactivatedSROP and EUR_CRM_Is_Active__c = true]){
            String key = '' + opm.EUR_CRM_Account__r.ownerid + opm.EUR_CRM_ObjPromo__c;
            if(deactivatedSROPCombo.contains(key) && !deactivatedOPS.contains(opm.EUR_CRM_ObjPromo__c))
                deactivateOPAccountMappings.add(opm);
        }
        for(EUR_CRM_ObjPromo_Account_Mapping__c opm:deactivateOPAccountMappings){
            opm.EUR_CRM_Is_Active__c = false;
        }
        Savepoint sp = Database.setSavepoint();
        try{
            if(updateVisitActions != null && updateVisitActions.size() > 0)
                update updateVisitActions;
                
            if(updateOPTargets != null && updateOPTargets.size() > 0) {
                Map<Id, EUR_CRM_ObjPromo_Target__c> updateOPTargetsMap = new Map<Id, EUR_CRM_ObjPromo_Target__c>();
                for(EUR_CRM_ObjPromo_Target__c opTarget: updateOPTargets) {
                    if(updateOPTargetsMap.get(opTarget.Id) == null) {
                        updateOPTargetsMap.put(opTarget.Id, opTarget);
                    }
                }
                
                update updateOPTargetsMap.values();
                //update new List<EUR_CRM_ObjPromo_Target__c>(updateOPTargets);
            }
                
            if(updateOPs != null && updateOPs.size() > 0)
                update updateOPs.values();
                
            if(updateVisitSubActions!= null && updateVisitSubActions.size() > 0)
                update updateVisitSubActions.values();
                
            if(updateOPACcountMapping!= null && updateOPACcountMapping.size() > 0)
                update updateOPACcountMapping;
                
            if(deactivateOPAccountMappings!= null && deactivateOPAccountMappings.size() > 0)
                update deactivateOPAccountMappings;
                
            system.debug('### opTargetMap: ' + updateVisitActions);
            system.debug('### updateOPTargets: ' + updateOPTargets);
            system.debug('### updateOPs: ' + updateOPs);
            system.debug('### updateVisitSubActions: ' + updateVisitSubActions);
            system.debug('### updateOPACcountMapping: ' + updateOPACcountMapping);
            system.debug('### deactivateOPAccountMappings: ' + deactivateOPAccountMappings); 
        }catch(DMLException e){
            Database.rollback(sp); 
            system.debug('### error savine the accruals: ' + e);
        }
    }
 
}