global class EUR_CRM_DERU_AccrueAchievements implements Database.Batchable<sObject>, Schedulable{
    public static String sched = '0 00 * * * ?';
    public static String JOBTYPE = 'BatchApex';
    public static String STATUS_PROCESSING = 'Processing';
    public static String STATUS_PREPARING = 'Preparing';
    public static String JOB_NAME = 'Accrue Germany and Russian Objective Achievements';
    public static String JOB_NAME_RETRY = 'Accrue Germany and Russian Objective Achievements Retry';
    public static Datetime dt= Datetime.now() + (0.00138);
    public static String timeForScheduler= dt.format('s m H d M \'?\' yyyy'); 
    //DE
    /*
    - have End date greater than or equal to O/P Start Date 
      but less than or equal to O/P End Date
    - are linked to O/P in which Batch Apex execution time 
      is greater than or equal to O/P Start Date but less than or equal to O/P End Date
    - have fields Is Successful AND Entitle Achievement = TRUE
    - When looking at an O/P header summary page, the user should be able to see all achievements against the O/P SR Target.
    - Based on Visit Action record type, create achievement record of same type, with link to Visit Action, O/P, and SR Target
    - Roll up summary should be displayed for all individual SR Achievements (1 SR) to date, against the same type of SR target (his/her target)
    - Rollup summary should be displayed for all SR's achievements to date against the Taxonomy Target / Regional Target
    - Target naming and record types may be changed to fit the purposes of the O/P, I'll let you know when I have evaluated them.
    */    
    public static Set<String> visitFieldsDE = new Set<String>{'RecordTypeId','RecordType.DeveloperName','EUR_CRM_ObjPromo__c',
    		'EUR_CRM_ObjPromo_Target__c','EUR_CRM_End_Datetime__c','EUR_CRM_IS_successful__c','EUR_CRM_Sell_In_Volume_Bottles__c',
    		'EUR_CRM_Sell_In_Volume_Total_SKU_Bottles__c'};
	public static Set<String> validRecordTypesDE = new Set<String>{'EUR_DE_OFF_2nd_PL_Do_TMKT_Doc','EUR_DE_OFF_2nd_PL_Present_Theme',
			'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Carton','EUR_DE_OFF_2nd_PL_Sell_In_Qty_Gondelkopf','EUR_DE_OFF_2nd_PL_Sell_In_Qty_Promo_Display',
			'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Razz_Fazz','EUR_DE_OFF_2nd_PL_Sell_In_Qty_Standard','EUR_DE_OFF_2nd_PL_Sell_In_Qty_Theme',
			'EUR_CRM_DE_OFF_Ad_Hoc_Rapunzel_Sell_In_Qty','EUR_DE_OFF_Ad_Hoc_Sell_In_Qty','DE_OFF_Ad_hoc_Agree_To_Buy',
			'EUR_DE_OFF_Dist_Drive_Listing_Check','EUR_DE_OFF_Leaflet_Campaign_Agree_To_Buy','EUR_DE_OFF_Leaflet_Campaign_Sell_In_Qty',
			'EUR_DE_OFF_Sales_Drive_SKU_Bottles_Sell_In_Qty','EUR_DE_OFF_Sales_Drive_SKU_Displays_Sell_In_Qty','EUR_DE_OFF_Sales_Drive_Sell_In_Qty',
			'EUR_DE_OFF_Tasting_Discussion','EUR_DE_OFF_Tasting_Sell_In_Qty','EUR_DE_OFF_Trade_Fair_Sell_In_Qty',
			'EUR_DE_ON_Ad_Hoc_Sell_In_Qty','EUR_DE_ON_TMKT_Promo_Confirm_Participation','EUR_DE_ON_TMKT_Promo_Enter_Sell_In_Qty',
			'EUR_DE_ON_TMKT_Promo_Presentation','EUR_DE_WS_Ad_Hoc_Sell_In_Qty','EUR_DE_WS_Confirm_Participation',
			'EUR_DE_WS_Do_Presentation','EUR_DE_WS_Enter_Sell_in_Qty'};
    public static String SALES_DRIVE_SELL_IN_QTY = 'EUR_DE_OFF_Sales_Drive_Sell_In_Qty';
    public static Set<String> SALES_DRIVES = new Set<String>{'EUR_DE_OFF_Sales_Drive_Sell_In_Qty','EUR_DE_OFF_Sales_Drive_SKU_Bottles_Sell_In_Qty','EUR_DE_OFF_Sales_Drive_SKU_Displays_Sell_In_Qty', 'EUR_DE_WS_Ad_Hoc_Sell_In_Qty', 'EUR_DE_WS_Enter_Sell_in_Qty'};
    public static String SECONDARY_PLACEMENT_THEME_SELL_IN_QTY = 'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Theme';
	//RU
	public static Set<String> visitFieldsRU = new Set<String>{'RecordTypeId','RecordType.DeveloperName','OwnerId','EUR_CRM_ObjPromo__c',
			'EUR_CRM_ObjPromo_Target__c','EUR_CRM_Account__c','EUR_CRM_Status__c','EUR_CRM_Is_Accrued__c','EUR_CRM_Promo_Kit_Quantity__c',
			'EUR_CRM_ObjPromo_Target__r.EUR_CRM_Actual_Quantity_Promo_Kits__c','EUR_CRM_ObjPromo_Target__r.EUR_CRM_Actual_Volume_Bottles__c',
			'EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__c'};
    global static final Set<String> validRecordTypesRU = new Set<String>{'EUR_RU_ON_Enter_Promo_Kit_Quantity','EUR_RU_OFF_ConfParticipationLoyaltyPOSMPlacement'};
    global static final Set<String> QUANTITY_BASED = new Set<String>{'EUR_RU_ON_Enter_Promo_Kit_Quantity'};
    global static final Set<String> VOLUME_BASED = new Set<String>{'EUR_RU_OFF_ConfParticipationLoyaltyPOSMPlacement'};			

    global static String schedule() {
        EUR_CRM_DERU_AccrueAchievements  SC = new EUR_CRM_DERU_AccrueAchievements(); 
        return System.schedule(JOB_NAME, sched, SC);
    }

    global void execute(SchedulableContext sc) {
        if ([SELECT count() FROM AsyncApexJob WHERE JobType=:JOBTYPE AND (Status =:STATUS_PROCESSING OR Status =:STATUS_PREPARING)] < 5){ 
            EUR_CRM_DERU_AccrueAchievements b1 = new EUR_CRM_DERU_AccrueAchievements ();
            Id batchprocessid = Database.executeBatch(b1,50);  
        }else {
            //schedule this same schedulable class again in 30 mins
            EUR_CRM_DERU_AccrueAchievements scRetry = new EUR_CRM_DERU_AccrueAchievements(); 
            Id schedId = System.Schedule(JOB_NAME_RETRY+timeForScheduler,timeForScheduler,scRetry);
        }
    }

    global static String generateQuery(){ 
        Set<String> visitFields = new Set<String>();
        visitFields.addAll(visitFieldsDE);
        visitFields.addAll(visitFieldsRU);
        List<String> validRecordTypes = new List<String>();
        validRecordTypes.addAll(validRecordTypesRU);
        validRecordTypes.addAll(validRecordTypesDE);
        String q ='SELECT Id,Name,'+String.join(new List<String>(visitFields), ','); 
        q +=' FROM EUR_CRM_Visit_Action__c';
        q +=' WHERE RecordType.DeveloperName IN (\''+String.join(validRecordTypes, '\',\'')+'\')';
        q +=' AND EUR_CRM_Entitle_Achievement__c = TRUE ';
        q +=' AND EUR_CRM_Is_Accrued__c = false';
        System.debug('### query: ' + q);
        return q;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(generateQuery());
    }

    global void execute(Database.BatchableContext BC, List<sObject>scope){	    
	    accrue(new List<EUR_CRM_Visit_Action__c>((List<EUR_CRM_Visit_Action__c>)scope));
    }

    global void finish(Database.BatchableContext BC){

    }

	public static void accrue(List<EUR_CRM_Visit_Action__c> visitActions){
        Set<Id> objPromoIds = new Set<Id>();
        List<EUR_CRM_Visit_Action__c> visitActionsToUpdate = new List<EUR_CRM_Visit_Action__c>();
        Map<Id, EUR_CRM_ObjPromo_Target__c> targetsToUpdate = new Map<Id, EUR_CRM_ObjPromo_Target__c>();
        List<EUR_CRM_ObjPromo_Achievement__c> achievementsToInsert = new List<EUR_CRM_ObjPromo_Achievement__c>();
        Set<Id> spThemeVisitActionIds = new Set<Id>();
        Map<Id,List<EUR_CRM_Visit_Sub_Action__c>> visitActionSubMap = new Map<Id,List<EUR_CRM_Visit_Sub_Action__c>>();

        //Map<Id,Set<Id>> targetActionsMap = new Map<Id,Set<Id>>();
        //Map<Id,EUR_CRM_Visit_Action__c> visitActionsMap = new Map<Id,EUR_CRM_Visit_Action__c>();
        Map<String,Id> achievementRecordTypes = getRecordTypesDevNameBySobject('EUR_CRM_ObjPromo_Achievement__c');
        Set<Id> targetIds = new Set<Id>();
        for(EUR_CRM_Visit_Action__c visitAction : visitActions){
            objPromoIds.add(visitAction.EUR_CRM_ObjPromo__c);
            targetIds.add(visitAction.EUR_CRM_ObjPromo_Target__c);
            targetIds.add(visitAction.EUR_CRM_ObjPromo_Target__r.EUR_CRM_O_P_Target__c);            

            if(SECONDARY_PLACEMENT_THEME_SELL_IN_QTY == visitAction.RecordType.DeveloperName){
                spThemeVisitActionIds.add(visitAction.id);
            }
        }
        targetIds.remove(null);

        Map<Id, EUR_CRM_ObjPromo__c> objPromoMap = new Map<Id, EUR_CRM_ObjPromo__c>(
        	[SELECT Id, EUR_CRM_Active_End_Date__c,EUR_CRM_Active_Start_Date__c	FROM EUR_CRM_ObjPromo__c WHERE Id IN: objPromoIds]);
        Map<id,EUR_CRM_ObjPromo_Target__c> targetsMap = new Map<id,EUR_CRM_ObjPromo_Target__c>(
        	[SELECT Id,EUR_CRM_Actual_Volume_Bottles__c,EUR_CRM_Actual_Volume_Displays__c,EUR_CRM_Actual_Quantity_Promo_Kits__c,EUR_CRM_O_P_Target__c FROM EUR_CRM_ObjPromo_Target__c WHERE Id IN: targetIds ]);

        //extract all the non-accrued sub actions of secondary them placements visit actions
        if(spThemeVisitActionIds.size() > 0){
            for(EUR_CRM_Visit_Sub_Action__c subAction : [SELECT Id, EUR_CRM_Is_Accrued__c, EUR_CRM_Number_of_Bottles__c,
                        EUR_CRM_Number_of_Cartons__c, EUR_CRM_Number_of_Displays__c, EUR_CRM_Display_Type__c, EUR_CRM_Visit_Action__c
                    FROM EUR_CRM_Visit_Sub_Action__c
                    WHERE EUR_CRM_Visit_Action__c IN:spThemeVisitActionIds AND EUR_CRM_Is_Accrued__c = false ]){
                if(!visitActionSubMap.containsKey(subAction.EUR_CRM_Visit_Action__c)){
                    visitActionSubMap.put(subAction.EUR_CRM_Visit_Action__c, new List<EUR_CRM_Visit_Sub_Action__c>());
                }
                visitActionSubMap.get(subAction.EUR_CRM_Visit_Action__c).add(subAction);
            }
        }

        for(EUR_CRM_Visit_Action__c visitAction: visitActions){
            try{
    		String recordTypeDevName = visitAction.RecordType.DeveloperName;
    		System.debug('@@@ visitAction' + visitAction );
	        System.debug('@@@ recordTypeDevName ' + recordTypeDevName );

    		if(validRecordTypesDE.contains(recordTypeDevName)){ //DE process
	            EUR_CRM_ObjPromo__c objPromo = objPromoMap.get(visitAction.EUR_CRM_ObjPromo__c);
	            System.debug('@@@ objPromo ' + objPromo );
	            DateTime vEndDate = visitAction.EUR_CRM_End_Datetime__c;
	            Date visitActionEndDate =  date.newinstance(vEndDate.year(), vEndDate.month(), vEndDate.day());

	            if(visitAction.EUR_CRM_End_Datetime__c != null && objPromo != null && objPromo.EUR_CRM_Active_Start_Date__c != null &&
	               		visitActionEndDate >= objPromo.EUR_CRM_Active_Start_Date__c && visitActionEndDate <= objPromo.EUR_CRM_Active_End_Date__c &&
	               		targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c) != null){
	               	if(visitAction.EUR_CRM_Is_Successful__c){
	                    Id rtId = achievementRecordTypes.get(visitAction.RecordType.DeveloperName);
	                    EUR_CRM_ObjPromo_Achievement__c achievement = new EUR_CRM_ObjPromo_Achievement__c(
	                        EUR_CRM_ObjPromo_Target__c = visitAction.EUR_CRM_ObjPromo_Target__c,
	                        EUR_CRM_ObjPromo__c = visitAction.EUR_CRM_ObjPromo__c,
	                        EUR_CRM_Visit_Action__c = visitAction.id,
	                        RecordTypeId = rtId
	                    );
	                    achievementsToInsert.add(achievement);
	                }
	                if( SALES_DRIVES.contains(recordTypeDevName)){
	                //sales drive
	                    //Decimal volBottle = visitAction.EUR_CRM_Sell_In_Volume_Bottles__c == null?0:visitAction.EUR_CRM_Sell_In_Volume_Bottles__c;
	                    //DEC.18.2014 change from EUR_CRM_Sell_In_Volume_Bottles__c to EUR_CRM_Sell_In_Volume_Total_SKU_Bottles__c
	                    system.debug('@@@ sales drive' + visitAction.EUR_CRM_Sell_In_Volume_Total_SKU_Bottles__c);
	                    Decimal volBottle = visitAction.EUR_CRM_Sell_In_Volume_Total_SKU_Bottles__c== null?0:visitAction.EUR_CRM_Sell_In_Volume_Total_SKU_Bottles__c;
	                    Decimal totalBottle = targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c).EUR_CRM_Actual_Volume_Bottles__c;
	                    totalBottle = totalBottle == null ? 0 : totalBottle;
	                    totalBottle += volBottle;
	                    targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c).EUR_CRM_Actual_Volume_Bottles__c = totalBottle;
	                    targetsToUpdate.put(visitAction.EUR_CRM_ObjPromo_Target__c, targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c));
	                }else if(SECONDARY_PLACEMENT_THEME_SELL_IN_QTY == recordTypeDevName){
	                    System.debug('@@@ secondary theme placement' );
	                    Decimal volBottle = retrieveTotalNumberOfBottles(visitActionSubMap.get(visitAction.id));
	                    Decimal totalBottle = targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c).EUR_CRM_Actual_Volume_Bottles__c;
	                    system.debug('@@@ totalBottle '  +totalBottle );
	                    system.debug('@@@ volBottle '  +volBottle );
	                    totalBottle = totalBottle == null ? 0 : totalBottle;
	                    totalBottle += volBottle;
	                    targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c).EUR_CRM_Actual_Volume_Bottles__c = totalBottle;
	                    targetsToUpdate.put(visitAction.EUR_CRM_ObjPromo_Target__c, targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c));
	                }else {
	                    //if('EUR_DE_OFF_2nd_Placement_Sell_In_Qty' == recordTypesMap.get(visitAction.recordTypeid).developername){
	                    //secondary placement
	                    Decimal volBottle = visitAction.EUR_CRM_Sell_In_Volume_Bottles__c == null?0:visitAction.EUR_CRM_Sell_In_Volume_Bottles__c;
	                    Decimal totalBottle = targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c).EUR_CRM_Actual_Volume_Bottles__c;
	                    system.debug('@@@ not sales drive');
	                    totalBottle = totalBottle == null ? 0 : totalBottle;
	                    totalBottle += volBottle;
	                    targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c).EUR_CRM_Actual_Volume_Bottles__c = totalBottle;
	                    targetsToUpdate.put(visitAction.EUR_CRM_ObjPromo_Target__c, targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c)); 
	                 }
	                //mark the visit action as 'accrued' except for secondary theme placements
	                visitAction.EUR_CRM_Is_Accrued__c = true;
	                visitActionsToUpdate.add(visitAction);
	            }

	        }else if(validRecordTypesRU.contains(recordTypeDevName)){//RU process
                if(visitAction.EUR_CRM_ObjPromo_Target__c != null && targetsMap.containsKey(visitAction.EUR_CRM_ObjPromo_Target__c)){
                    EUR_CRM_ObjPromo_Target__c target = targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c);

                    if(QUANTITY_BASED.contains(visitAction.RecordType.DeveloperName)){
                        if(visitAction.EUR_CRM_Promo_Kit_Quantity__c != null &&
                        		visitAction.EUR_CRM_ObjPromo_Target__c != null &&
                           		visitAction.EUR_CRM_Status__c == 'Yes'){
                            Decimal quantity = (Decimal.valueOf(visitAction.EUR_CRM_Promo_Kit_Quantity__c));
                            target.EUR_CRM_Actual_Quantity_Promo_Kits__c += quantity;
                            visitAction.EUR_CRM_Is_Accrued__c = true;
                            visitActionsToUpdate.add(visitAction);
                            targetsToUpdate.put(visitAction.EUR_CRM_ObjPromo_Target__c, target); 
                            if(target.EUR_CRM_O_P_Target__c != null && targetsMap.get(target.EUR_CRM_O_P_Target__c) != null){
                                targetsMap.get(target.EUR_CRM_O_P_Target__c).EUR_CRM_Actual_Quantity_Promo_Kits__c += quantity;
                                targetsToUpdate.put(target.EUR_CRM_O_P_Target__c, targetsMap.get(target.EUR_CRM_O_P_Target__c)); 
                            }
                        }
                    }
                    else if(VOLUME_BASED.contains(visitAction.RecordType.DeveloperName)){
                        if(visitAction.EUR_CRM_ObjPromo_Target__c != null && visitAction.EUR_CRM_Status__c == 'Participating'){
                            target.EUR_CRM_Actual_Volume_Bottles__c = (target.EUR_CRM_Actual_Volume_Bottles__c!=null)? target.EUR_CRM_Actual_Volume_Bottles__c+1: 1;
                            visitAction.EUR_CRM_Is_Accrued__c = true;
                            visitActionsToUpdate.add(visitAction);
                            targetsToUpdate.put(visitAction.EUR_CRM_ObjPromo_Target__c, target);
                            //if(target.EUR_CRM_O_P_Target__c != null && targetsMap.get(target.EUR_CRM_O_P_Target__c) != null){
                            //    EUR_CRM_ObjPromo_Target__c parentTarget = targetsMap.get(target.EUR_CRM_O_P_Target__c);
                            //    parentTarget.EUR_CRM_Actual_Volume_Bottles__c = (parentTarget.EUR_CRM_Actual_Volume_Bottles__c!=null)? parentTarget.EUR_CRM_Actual_Volume_Bottles__c+1: 1;
                            //    targetsToUpdate.put(target.EUR_CRM_O_P_Target__c, parentTarget);
                            //}
                        }
                    }
                }                    

	        }

            }catch(Exception e){
                system.debug('@@@ error while traversing the list of visict action: ' + visitAction);
                continue;
            }
        }

        Savepoint sp = Database.setSavepoint();
        try{
            System.debug('!! Inserting');
            System.debug('!! Inserting achievementsToInsert ' + achievementsToInsert.size());
            System.debug('!! Inserting visitActionsToUpdate' + visitActionsToUpdate.size());
            if(!achievementsToInsert.isEmpty()){
            	insert achievementsToInsert;
            }
            if(!visitActionsToUpdate.isEmpty()){
            	update visitActionsToUpdate;
            }
            if(!targetsToUpdate.isEmpty()){
                update targetsToUpdate.values();
            }
            if(!visitActionSubMap.isEmpty()){
                List<EUR_CRM_Visit_Sub_Action__c> subActionsUpdate = new List<EUR_CRM_Visit_Sub_Action__c>();
                for(Id key :visitActionSubMap.keySet()){
                     subActionsUpdate.addAll(visitActionSubMap.get(key));
                }
                for(EUR_CRM_Visit_Sub_Action__c subAction : subActionsUpdate){
                    subAction.EUR_CRM_Is_Accrued__c = true;
                }
                if(!subActionsUpdate.isEmpty()){
                    update subActionsUpdate;
                }
            }
        }catch(DMLException e){
            system.debug('!! Error in insert/update');
            system.debug(e);
            Database.rollback(sp);
        }
	}

	private static Map<String, Id> getRecordTypesDevNameBySobject(String objectAPIName){
    	Map<String, Id> mapRTDevNameToId = new Map<String, Id>();
        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objectAPIName);
        if(sObjType == null){ return mapRTDevNameToId; }
        Schema.DescribeSObjectResult cfrSchema = sObjType.getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = cfrSchema.getRecordTypeInfosByDeveloperName();
        for(Schema.RecordTypeInfo rti: recordTypeInfo.values()){
        	mapRTDevNameToId.put(rti.getDeveloperName(), rti.getRecordTypeId());
        }
        return mapRTDevNameToId;
    }

    private Static Decimal retrieveTotalNumberOfBottles(List<EUR_CRM_Visit_Sub_Action__c> subActions){
        Decimal total = 0;
        if(subActions != null)
        for(EUR_CRM_Visit_Sub_Action__c subAction : subActions){
            total += subAction.EUR_CRM_Number_of_Bottles__c == null ? 0 : subAction.EUR_CRM_Number_of_Bottles__c;
        }
        return total;
    }

}