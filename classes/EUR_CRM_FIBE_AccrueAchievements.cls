global class EUR_CRM_FIBE_AccrueAchievements implements Database.Batchable<sObject>, Schedulable{
    public static String sched = '0 00 * * * ?';
    public static String JOBTYPE = 'BatchApex';
    public static String STATUS_PROCESSING = 'Processing';
    public static String STATUS_PREPARING = 'Preparing';
    public static String JOB_NAME = 'Accrue Finland and Belgium Objective Achievements';
    public static String JOB_NAME_RETRY = 'Accrue Finland and Belgium Objective Achievements Retry';
    public static Datetime dt= Datetime.now() + (0.00138);
    public static String timeForScheduler= dt.format('s m H d M \'?\' yyyy'); 
 
    global static String schedule() {
        EUR_CRM_FIBE_AccrueAchievements  SC = new EUR_CRM_FIBE_AccrueAchievements(); 
        return System.schedule(JOB_NAME, sched, SC);
    }

    global void execute(SchedulableContext sc) {
        if ([SELECT count() FROM AsyncApexJob WHERE JobType=:JOBTYPE AND (Status =:STATUS_PROCESSING OR Status =:STATUS_PREPARING)] < 5){ 
            EUR_CRM_FIBE_AccrueAchievements b1 = new EUR_CRM_FIBE_AccrueAchievements ();
            Id batchprocessid = Database.executeBatch(b1,50);  
        }else {
            //schedule this same schedulable class again in 30 mins
            EUR_CRM_FIBE_AccrueAchievements scRetry = new EUR_CRM_FIBE_AccrueAchievements(); 
            Id schedId = System.Schedule(JOB_NAME_RETRY+timeForScheduler,timeForScheduler,scRetry);
        }       
    }

    global static String generateQuery(){ 
        Set<String> visitFields = new Set<String>();
        visitFields.addAll(visitFieldsFI);
        visitFields.addAll(visitFieldsBE);
        List<String> validRecordTypes = new List<String>();
        validRecordTypes.addAll(validRecordTypesFI);
        validRecordTypes.addAll(validRecordTypesBE);
        String q ='SELECT Id,Name,'+String.join(new List<String>(visitFields), ','); 
        q +=' FROM EUR_CRM_Visit_Action__c';
        q +=' WHERE RecordType.DeveloperName IN (\''+String.join(validRecordTypes, '\',\'')+'\')';
        q +=' AND EUR_CRM_Is_Accrued__c = false';
        System.debug('### query: ' + q);
        return q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(generateQuery());
    }
    
    global void execute(Database.BatchableContext BC, List<sObject>scope){
	    List<EUR_CRM_Visit_Action__c> lstVisitActionBE = new List<EUR_CRM_Visit_Action__c>();
	    List<EUR_CRM_Visit_Action__c> lstVisitActionFI = new List<EUR_CRM_Visit_Action__c>();
	    for(EUR_CRM_Visit_Action__c va: (List<EUR_CRM_Visit_Action__c> )scope){
	    	if(validRecordTypesBE.contains(va.RecordType.DeveloperName)){
	    		lstVisitActionBE.add(va);
	    	}else if(validRecordTypesFI.contains(va.RecordType.DeveloperName)){
	    		lstVisitActionFI.add(va);
	    	}
	    }
	    accrueBE(lstVisitActionBE);
	    accrueFI(lstVisitActionFI);
    }
   
    global void finish(Database.BatchableContext BC){
		EUR_CRM_BE_MassDeactivateOPAccMapping batchJob = new EUR_CRM_BE_MassDeactivateOPAccMapping();
	    Id batchId = Database.executeBatch(batchJob,200);    
    }

//=======================================FI PART========================================================================
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
    static List<String> visitFieldsFI = new List<String>{'EUR_CRM_Visit_Id__c','EUR_CRM_Account__c','EUR_CRM_Account__r.OwnerId',
        'EUR_CRM_ObjPromo__c','EUR_CRM_ObjPromo__r.EUR_CRM_Status__c','EUR_CRM_Status__c','EUR_CRM_ObjPromo_Target__c',
        'OwnerId','RecordType.DeveloperName'};

    static String VISIT_ACTION_CONFIRM_PARTICIPATION = 'EUR_FI_Confirm_Participation';
    static String VISIT_ACTION_ENTER_SELL_IN_VOLUME = 'EUR_FI_Enter_Sell_In_Volume_Estimate';
    static String VISIT_ACTION_FOLLOW_UP_TYPE_1 = 'EUR_FI_Follow_Up_Type_1';
    static String VISIT_ACTION_FOLLOW_UP_TYPE_2 = 'EUR_FI_Follow_Up_Type_2';
    static String VISIT_ACTION_PRESENTATION = 'EUR_FI_Presentation';
    static String VISIT_ACTION_ADDITIONAL_MATERIAL = 'EUR_FI_Record_Additional_Material';

    static String PARTICIPATING = 'Participating';
    static String ACTUALIZED= 'Actualized';
    static String EVALUATION_SUCCESSFUL = 'Evaluation: Successful';

    static List<String> validRecordTypesFI = new List<String>{
        'EUR_FI_Confirm_Participation',
        'EUR_FI_Enter_Sell_In_Volume_Estimate',
        'EUR_FI_Follow_Up_Type_2',
        'EUR_FI_Follow_Up_Type_1'//,
    //    'EUR_FI_Presentation',
    //    'EUR_FI_Record_Additional_Material'
    };

    global static void accrueFI(List<EUR_CRM_Visit_Action__c> visitActions){
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
                	&& visitAction.EUR_CRM_Status__c == PARTICIPATING){             
                commitmentOPs.add(visitAction.EUR_CRM_ObjPromo__c);
                if(visitAction.EUR_CRM_Account__c != null){
                    if(!targetOwnerToVisitActionMap.containsKey(visitAction.EUR_CRM_Account__r.OwnerId)) {
                        targetOwnerToVisitActionMap.put(visitAction.EUR_CRM_Account__r.OwnerId, new List<EUR_CRM_Visit_Action__c>());
                    }
                    targetOwnerToVisitActionMap.get(visitAction.EUR_CRM_Account__r.OwnerId).add(visitAction);  
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
            else if(VISIT_ACTION_FOLLOW_UP_TYPE_1 == visitAction.recordType.developername ||
                	VISIT_ACTION_FOLLOW_UP_TYPE_2 == visitAction.recordType.developername  ){
                if(visitAction.EUR_CRM_ObjPromo__c!=null && visitAction.EUR_CRM_ObjPromo__r.EUR_CRM_Status__c=='Under Evaluation' 
                		&& visitAction.EUR_CRM_Account__c != null && visitAction.EUR_CRM_Status__c == EVALUATION_SUCCESSFUL){
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
                if(!targetOwnerToOPTargetMap.containsKey(target.EUR_CRM_Target_Owner__c)) {
                    targetOwnerToOPTargetMap.put(target.EUR_CRM_Target_Owner__c, new List<EUR_CRM_ObjPromo_Target__c>());
                }
                targetOwnerToOPTargetMap.get(target.EUR_CRM_Target_Owner__c).add(target);
                parentOps.add(target.EUR_CRM_O_P_Target__c);
            }
            
            System.debug(targets);
            System.debug(targetOwnerToOPTargetMap);
            
            opParentTargetMap = new Map<Id,EUR_CRM_ObjPromo_Target__c>([select id,EUR_CRM_ObjPromo__c,EUR_CRM_Visit_Targets__c,EUR_CRM_Is_Quota__c, EUR_CRM_Actual_Number_of_Commitments__c from EUR_CRM_ObjPromo_Target__c where id in:parentOps]);
            
            System.debug(targetOwnerToVisitActionMap);
            System.debug(parentOps);
            System.debug(opParentTargetMap);
            
            for(EUR_CRM_ObjPromo_Target__c opTarget: targets.values()){
                if(targetOwnerToVisitActionMap.containsKey(opTarget.EUR_CRM_Target_Owner__c)) {
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
                    //if(parentTarget != null){     
                        //Decimal currentParentQty = parentTarget.EUR_CRM_Actual_Volume_Bottles__c == null ? 0 : parentTarget.EUR_CRM_Actual_Volume_Bottles__c; 
                        //parentTarget.EUR_CRM_Actual_Volume_Bottles__c = currentParentQty + subAction.EUR_CRM_Number_of_Bottles__c;
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

//======================================================BE PART========================================================

	/*static Map<String, String> validRecordTypesVolumeAPIMapping = new Map<String, String>{
		'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Carton' 		 => 'EUR_CRM_Sell_In_Volume_Bottles__c',
		'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Gondola' 		 => 'EUR_CRM_Sell_In_Volume_Bottles__c',
		'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Promo_Display' => 'EUR_CRM_Sell_In_Volume_Bottles__c',
		'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Standard' 	 => 'EUR_CRM_Sell_In_Volume_Bottles__c',
		'EUR_DK_OFF_2nd_Placement_Sell_In_Qty_Theme' 		 => 'EUR_CRM_Sell_In_Volume_Bottles__c',
		'EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Bottles' 	 => 'EUR_CRM_Sell_In_Volume_SKUs__c',
		'EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Cartons' 	 => 'EUR_CRM_Sell_In_Volume_SKUs__c',
		'EUR_DK_OFF_SalesDriveSKU_EnterSellInQty_Displays'	 => 'EUR_CRM_Sell_In_Volume_SKUs__c'
	};*/
	static Set<String> visitFieldsBE = new Set<String>{'EUR_CRM_Visit_Id__c','EUR_CRM_Account__c','EUR_CRM_Account__r.OwnerId',
						'EUR_CRM_ObjPromo__c','EUR_CRM_ObjPromo__r.EUR_CRM_Status__c','EUR_CRM_Status__c',
						'EUR_CRM_ObjPromo_Target__c','EUR_CRM_Sell_In_Volume_Bottles__c','EUR_CRM_Sell_In_Volume_Displays__c','EUR_CRM_Sell_In_Volume_SKUs__c','EUR_CRM_No_of_Spyder_Displays_Placed__c','EUR_CRM_Quantity_of_Kits__c',
						'EUR_CRM_SKU__c','EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c','EUR_CRM_Brand_Quality__c','EUR_CRM_Brand_Quality_Size__c','OwnerId','RecordType.DeveloperName'};

	//Value are prioritized to only accual the first one if more than one in capture field
	//VA : RecordType to fields that capture value 
	static Map<String,String> validOPRecordTypesBE = New Map<String,String>{
		'EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty' => 'EUR_CRM_Sell_In_Volume_Bottles__c,EUR_CRM_Sell_In_Volume_Displays__c',
		'EUR_BE_OFF_Secondary_Placement_ConfParticipation' => 'EUR_CRM_No_of_Spyder_Displays_Placed__c',
		'EUR_BE_ON_PromoKitActivation_Enter_Sell_In_Qty' => 'EUR_CRM_Sell_In_Volume_Bottles__c,EUR_CRM_Quantity_of_Kits__c'
	};
    
    //Fields updated in a trigger
    static Set<String> qtyFieldsInTrigger = new Set<String>{'EUR_CRM_Sell_In_Volume_Bottles__c','EUR_CRM_Sell_In_Volume_Displays__c'};

	//Visit Action Capture Field to OPTarget Accrual Field
	static Map<String,String> accualQtyToTargetMap = New Map<String,String>{
		'EUR_CRM_Sell_In_Volume_Bottles__c' => 'EUR_CRM_Actual_Volume_Bottles__c',
		'EUR_CRM_Sell_In_Volume_Displays__c' => 'EUR_CRM_Actual_Volume_Displays__c',
		'EUR_CRM_No_of_Spyder_Displays_Placed__c' => 'EUR_CRM_Actual_Quantity_Spyder__c',
		'EUR_CRM_Quantity_of_Kits__c' => 'EUR_CRM_Actual_Quantity_Promo_Kits__c'
	};
	//VA : RecordType to Require Product Or Not
	static Map<String,Boolean> productKeyRequired = New Map<String,Boolean>{
		'EUR_BE_OFF_Trade_Sales_Drive_Enter_Sell_In_Qty' => true,
		'EUR_BE_OFF_Secondary_Placement_ConfParticipation' => false
	};
	static Set<String> validRecordTypesBE = validOPRecordTypesBE.keySet();

	global static void accrueBE(List<EUR_CRM_Visit_Action__c> visitActions) {
        //System.Debug('@@@Start Accrual');
		//Map<String, Id> visitActionRecordTypes = new Map<String, Id>();
		List<EUR_CRM_Visit_Action__c> visitActionsToUpdate = new List<EUR_CRM_Visit_Action__c>();
		Set<Id> validOPIds = new Set<Id>();
		Set<Id> validVisitActionOwnerIds = new Set<Id>(); 
		Set<EUR_CRM_ObjPromo__c> OPSpyderTargetachievedSet = New Set<EUR_CRM_ObjPromo__c>();

		//If no visit action : Exit 
		if(visitActions == null || visitActions.size() == 0) {
            //System.Debug('@@@No VA');
			return;
		}

		// Retrieve Visit Action Record Types
		//for(RecordType rt: Global_RecordTypeCache.getRtList('EUR_CRM_Visit_Action__c')) {
		//	if(validRecordTypesBE.contains(rt.DeveloperName)) {
		//		visitActionRecordTypes.put(rt.DeveloperName, rt.Id);
		//	}
		//}
		//System.Debug('###VisitActions:Scope:' + visitActions);
		//System.Debug('###Valid Visit Action:' + visitActionRecordTypes);

		//Filter Visit Action By Record Type / Get list of op / Get List of target owner / Mark VA to accrued
		for(EUR_CRM_Visit_Action__c visitAction: visitActions) {
			if(validRecordTypesBE.contains(visitAction.RecordType.DeveloperName)) {
				validOPIds.add(visitAction.EUR_CRM_ObjPromo__c);
				if(visitAction.EUR_CRM_Account__c != null) {
					validVisitActionOwnerIds.add(visitAction.EUR_CRM_Account__r.OwnerId);
				}
				visitAction.EUR_CRM_Is_Accrued__c = true;
				visitActionsToUpdate.add(visitAction);
			}
		}

		

		List<EUR_CRM_ObjPromo_Target__c> opTargetsToUpdate = new List<EUR_CRM_ObjPromo_Target__c>();
		Map<Id, EUR_CRM_ObjPromo__c> opsToUpdate = new Map<Id, EUR_CRM_ObjPromo__c>();

		//System.Debug('###Owner' + validVisitActionOwnerIds);
		//System.Debug('###Visit Action to UPdate:' + visitActionsToUpdate);
		//System.Debug('###Valid Op Ids:' + validOpIds);

		//If there is valid visit action
		if(visitActionsToUpdate.size() > 0) {
			Map<String, EUR_CRM_ObjPromo_Target__c> opTargetMap = new Map<String, EUR_CRM_ObjPromo_Target__c>();
			Map<Id, EUR_CRM_ObjPromo_Target__c> opParentTargetMap = new Map<Id, EUR_CRM_ObjPromo_Target__c>();
			Set<Id> parentOps = new Set<Id>();

			//Create target mapping, key = ObjPromo + targetOwner + product
			for(EUR_CRM_ObjPromo_Target__c target: [select id,Name,EUR_CRM_O_P_Target__c,EUR_CRM_Visit_Targets__c, EUR_CRM_BQS__c,EUR_CRM_BQ__c,EUR_CRM_SKU__c,EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c,
				EUR_CRM_Actual_Volume_Bottles__c,EUR_CRM_Actual_Volume_Displays__c , EUR_CRM_Actual_Quantity_Spyder__c,EUR_CRM_Actual_Quantity_Promo_Kits__c, EUR_CRM_O_P_Target__r.EUR_CRM_O_P_Target__c,
				EUR_CRM_Target_Quantity_Spyders__c, EUR_CRM_ObjPromo__c,EUR_CRM_Target_Owner__c 
				from EUR_CRM_ObjPromo_Target__c 
                where EUR_CRM_Target_Owner__c in :validVisitActionOwnerIds AND EUR_CRM_ObjPromo__c in :validOPIds
                AND recordType.developername = 'EUR_BE_SR_Volume_Target']) {

				//System.Debug('>>>Create Key For:' + target);

				String key = '' + target.EUR_CRM_ObjPromo__c + target.EUR_CRM_Target_Owner__c;
				String prodkey = '';
				if(target.EUR_CRM_BQ__c != null) {
				    prodkey = target.EUR_CRM_BQ__c;
				} else if(target.EUR_CRM_BQS__c != null) {
				    prodkey = target.EUR_CRM_BQS__c;
				} else if(target.EUR_CRM_SKU__c != null) {
				    prodkey = target.EUR_CRM_SKU__c;
				} 
				key +=prodkey;

				//System.Debug('### target key: ' + key);
				opTargetMap.put(key, target);

				parentOps.add(target.EUR_CRM_O_P_Target__c);
				parentOps.add(target.EUR_CRM_O_P_Target__r.EUR_CRM_O_P_Target__c);
			}

			//System.Debug(parentOps);
			//System.Debug(opTargetMap);

			opParentTargetMap = new Map<Id, EUR_CRM_ObjPromo_Target__c>([SELECT Id,NAme, EUR_CRM_ObjPromo__c, EUR_CRM_Visit_Targets__c, EUR_CRM_Actual_Volume_Bottles__c,
																		 EUR_CRM_Actual_Volume_Displays__c,EUR_CRM_Actual_Quantity_Spyder__c,EUR_CRM_Actual_Quantity_Promo_Kits__c, EUR_CRM_O_P_Target__c,
																		 EUR_CRM_Target_Quantity_Spyders__c
																		 FROM EUR_CRM_ObjPromo_Target__c
																		 WHERE Id IN :parentOps]);
			//System.Debug(opParentTargetMap);

			//For each Visit action, get the target by key
			for(EUR_CRM_Visit_Action__c visitAction: visitActionsToUpdate) {
				//System.Debug('>>>>>>');
				//System.Debug('>>>Visit Avtion:' + visitAction);
				String key = '' + visitAction.EUR_CRM_ObjPromo__c + visitAction.EUR_CRM_Account__r.ownerId;
				String prodKey = '';

				//System.Debug(visitAction);

				/*if(visitAction.EUR_CRM_Brand_Quality__c != null) {
					prodKey = visitAction.EUR_CRM_Brand_Quality__c;
				} else */
				if(visitAction.EUR_CRM_Brand_Quality_Size__c != null) {
					prodKey = visitAction.EUR_CRM_Brand_Quality_Size__c;
				} else if(visitAction.EUR_CRM_SKU__c != null) {
					prodKey = visitAction.EUR_CRM_SKU__c;
				} else if(visitAction.EUR_CRM_Brand_Quality__c != null) {
					prodKey = visitAction.EUR_CRM_Brand_Quality__c;
				}
				key += prodKey;

				//System.Debug(key);
				EUR_CRM_ObjPromo_Target__c srtarget = opTargetMap.get(key);
				String quantityCaptureField = validOPRecordTypesBE.get(visitAction.recordType.DeveloperName);
				//System.Debug('srtarget:' + srtarget);
				//System.Debug('VA rt:' + visitAction.recordType.DeveloperName);
				//System.Debug('Capture field:' + quantityCaptureField);
				//System.debug(visitAction.get(quantityCaptureField));
				if(srtarget != null && quantityCaptureField != null) {
					List<String> qtyCaptureFieldList = quantityCaptureField.Split(',');
					//System.Debug('>>Capture:' + quantityCaptureField);
					For(String qtyCaptureField : qtyCaptureFieldList){
						//System.Debug('>>Capture field:' + qtyCaptureField);
						Decimal capturedValue = (Decimal)visitAction.get(qtyCaptureField);
						If(capturedValue != null && capturedValue > 0){
							Decimal currentQty = (Decimal)srtarget.get(accualQtyToTargetMap.get(qtyCaptureField)) == null ? 0 : (Decimal)srtarget.get(accualQtyToTargetMap.get(qtyCaptureField));
							srtarget.put(accualQtyToTargetMap.get(qtyCaptureField), currentQty + capturedValue); //Accual to SR Target

							//System.Debug('+++OPSR1:' + srtarget.Name +  '|' + accualQtyToTargetMap.get(qtyCaptureField) + '|' + currentQty + capturedValue);

							opTargetsToUpdate.add(srtarget);
							//System.Debug('>>>opTargetsToUpdate added:' + srtarget);
							EUR_CRM_ObjPromo_Target__c objectiveTarget = opParentTargetMap.get(srtarget.EUR_CRM_O_P_Target__c);

							if(objectiveTarget != null && !qtyFieldsInTrigger.contains(qtyCaptureField)) {
								//Decimal currentObjQty = (Decimal)objectiveTarget.get(accualQtyToTargetMap.get(qtyCaptureField)) == null ? 0 : (Decimal)objectiveTarget.get(accualQtyToTargetMap.get(qtyCaptureField));
								//objectiveTarget.put(accualQtyToTargetMap.get(qtyCaptureField), currentObjQty + capturedValue); //Accual to OP Target

								//Handle Spyder, If Target archived, Turn OP to Under Evaluation
								If(objectiveTarget.EUR_CRM_Target_Quantity_Spyders__c <= objectiveTarget.EUR_CRM_Actual_Quantity_Spyder__c){
                                    try{
                                        OPSpyderTargetachievedSet.add(new EUR_CRM_ObjPromo__c(
																		Id=objectiveTarget.EUR_CRM_ObjPromo__c,
																		EUR_CRM_Status__c = 'Under Evaluation'));
                                    }Catch(Exception e){
                                        //System.Debug('@@@@Avoid Duplicate');
                                    }

								}


								//System.Debug('+++OPT1:' + objectiveTarget.Name +  '|' + accualQtyToTargetMap.get(qtyCaptureField) + '|' + objectiveTarget.get(accualQtyToTargetMap.get(qtyCaptureField)));

								//System.Debug('>>>objectiveTarget updated:' + objectiveTarget);
							}

							/*SPECIAL HANDLING FOR DISPLAY TO BOTTLES*/
							If(qtyCaptureField == 'EUR_CRM_Sell_In_Volume_Displays__c'){
								Decimal currentBottleQty = (Decimal)srtarget.get('EUR_CRM_Actual_Volume_Bottles__c') == null ? 0 : (Decimal)srtarget.get('EUR_CRM_Actual_Volume_Bottles__c');
								srtarget.put('EUR_CRM_Actual_Volume_Bottles__c',currentBottleQty + (capturedValue * srtarget.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c));

								//System.Debug('+++OPSR2:' + srtarget.Name +  '|EUR_CRM_Actual_Volume_Bottles__c|' + currentBottleQty + (capturedValue * srtarget.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c));

								if(objectiveTarget != null) {
									Decimal currentObjBottleQty = (Decimal)objectiveTarget.get('EUR_CRM_Actual_Volume_Bottles__c') == null ? 0 : (Decimal)objectiveTarget.get('EUR_CRM_Actual_Volume_Bottles__c');
									objectiveTarget.put('EUR_CRM_Actual_Volume_Bottles__c', currentObjBottleQty + (capturedValue * srtarget.EUR_CRM_SKU__r.EUR_CRM_Bottles_per_Case__c)); //Accual to OP Target

									//System.Debug('+++OPT2:' + objectiveTarget.Name +  '|EUR_CRM_Actual_Volume_Bottles__c|' + objectiveTarget.get('EUR_CRM_Actual_Volume_Bottles__c'));

									//System.Debug('>>>objectiveTarget updated Bottle:' + objectiveTarget);
								}
							}

							

							break; //Only do the first qtyCapturefield
						}
					}
				}
			}

			if(opParentTargetMap != null && opParentTargetMap.values() != null && opParentTargetMap.values().size() > 0) {
				//System.Debug(opParentTargetMap);
				opTargetsToUpdate.addAll(opParentTargetMap.values());
			}

			//System.Debug('opTargetsToUpdate:' + opTargetsToUpdate);
			//System.Debug('visitActionsToUpdate:' + visitActionsToUpdate);

			Savepoint sp = Database.setSavepoint();
			try {
				if(visitActionsToUpdate != null && visitActionsToUpdate.size() > 0) {
                    //System.Debug('@@@Update:visitActionsToUpdate');
					update visitActionsToUpdate;
				}

				if(opTargetsToUpdate != null && opTargetsToUpdate.size() > 0) {
					Map<Id, EUR_CRM_ObjPromo_Target__c> opTargetsUpdateMap = new Map<Id, EUR_CRM_ObjPromo_Target__c>();
					for(EUR_CRM_ObjPromo_Target__c opTarget: opTargetsToUpdate) {
						if(opTargetsUpdateMap.get(opTarget.Id) == null) {
							opTargetsUpdateMap.put(opTarget.Id, opTarget);
						}
					}

					//System.Debug(opTargetsUpdateMap);
                    //System.Debug('@@@Update:opTargetsUpdateMap');
					update opTargetsUpdateMap.values();
				}

				//Trigger MassDeactivteOPAccMapping
				if(OPSpyderTargetachievedSet.Size() > 0){
                    For(EUR_CRM_ObjPromo__c op : OPSpyderTargetachievedSet){
                        //System.Debug('@@@@' + op);
                    }
                    
                    //System.Debug('@@@Update:OPSpyderTargetachievedSet');
                    List<EUR_CRM_ObjPromo__c> OPSpyderList = New List<EUR_CRM_ObjPromo__c>();
                    OPSpyderList.addall(OPSpyderTargetachievedSet);
					Update OPSpyderList;
					
				}
			} catch (DMLException e) {
				Database.rollback(sp);
				//System.Debug('ERROR' + e);
			}
		    
		}


	}
 
}