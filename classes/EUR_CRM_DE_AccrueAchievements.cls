/**
Batchable class to process all visit actions and create achievements
for Objectives & Promotions Module
*/
global class EUR_CRM_DE_AccrueAchievements implements Database.Batchable<sObject>{
    /**
    Select all visit actions where 
        'is successful'
        'Entitle Achivement'
        'not accrued'
         record type in ('');
    */
    String query = 'select id,EUR_CRM_End_Datetime__c,recordtype.developername, EUR_CRM_ObjPromo__c, '+
                   ' recordtypeid, EUR_CRM_ObjPromo_Target__c, EUR_CRM_IS_successful__c, '+
                  ' EUR_CRM_Sell_In_Volume_Bottles__c,EUR_CRM_Sell_In_Volume_Total_SKU_Bottles__c  from EUR_CRM_Visit_Action__c where'+
                  // ' EUR_CRM_Is_Successful__c = true AND'+
                   ' EUR_CRM_Entitle_Achievement__c = true AND'+
                   ' EUR_CRM_Account__r.EUR_CRM_Country_Code__c = \'DE\' AND' +
                   ' EUR_CRM_Is_Accrued__c = false';
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        accrue((List<EUR_CRM_Visit_Action__c>) scope);
    }
   
    global void finish(Database.BatchableContext BC){
    
    }
    /**
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
    public static String SALES_DRIVE_SELL_IN_QTY = 'EUR_DE_OFF_Sales_Drive_Sell_In_Qty';
    public static Set<String> SALES_DRIVES = new Set<String>{'EUR_DE_OFF_Sales_Drive_Sell_In_Qty','EUR_DE_OFF_Sales_Drive_SKU_Bottles_Sell_In_Qty','EUR_DE_OFF_Sales_Drive_SKU_Displays_Sell_In_Qty'};
    public static String SECONDARY_PLACEMENT_THEME_SELL_IN_QTY = 'EUR_DE_OFF_2nd_PL_Sell_In_Qty_Theme';
    public static void accrue(List<EUR_CRM_Visit_Action__c> visitActions){
        
        Set<Id> objPromoIds = new Set<Id>();
        List<EUR_CRM_Visit_Action__c> visitActionsToUpdate = new List<EUR_CRM_Visit_Action__c>();
        List<EUR_CRM_ObjPromo_Achievement__c> achievementsToInsert = new List<EUR_CRM_ObjPromo_Achievement__c>();
        Set<Id> spThemeVisitActionIds = new Set<Id>();
        Map<Id,List<EUR_CRM_Visit_Sub_Action__c>> visitActionSubMap = new Map<Id,List<EUR_CRM_Visit_Sub_Action__c>>();

        //Map<Id,Set<Id>> targetActionsMap = new Map<Id,Set<Id>>();
        //Map<Id,EUR_CRM_Visit_Action__c> visitActionsMap = new Map<Id,EUR_CRM_Visit_Action__c>();
        Map<String,Id> achievementRecordTypes = new Map<String,Id>();
        Map<Id,RecordType> recordTypesMap = new Map<Id,RecordType>(
            [select id, developername,SObjectType  from RecordType where SObjectType in('EUR_CRM_Visit_Action__c','EUR_CRM_ObjPromo_Achievement__c')]);
        for(Id key: recordTypesMap.keySet()){
            if(recordTypesMap.get(key).SObjectType == 'EUR_CRM_ObjPromo_Achievement__c'){
                achievementRecordTypes.put(recordTypesMap.get(key).developername,recordTypesMap.get(key).id);
            }
        }
        Set<Id> targetIds = new Set<Id>();
        for(EUR_CRM_Visit_Action__c visitAction : visitActions){
            objPromoIds.add(visitAction.EUR_CRM_ObjPromo__c);
            targetIds.add(visitAction.EUR_CRM_ObjPromo_Target__c);
            
            if(SECONDARY_PLACEMENT_THEME_SELL_IN_QTY == recordTypesMap.get(visitAction.recordTypeid).developername)
                spThemeVisitActionIds.add(visitAction.id);
        }
                    
        Map<Id, EUR_CRM_ObjPromo__c> objPromoMap = new Map<Id, EUR_CRM_ObjPromo__c>(
        [select id, EUR_CRM_Active_End_Date__c,EUR_CRM_Active_Start_Date__c 
            from EUR_CRM_ObjPromo__c 
                where id in: objPromoIds]);
        Map<id,EUR_CRM_ObjPromo_Target__c> targetsMap= new Map<id,EUR_CRM_ObjPromo_Target__c>();
        targetsMap = new Map<id,EUR_CRM_ObjPromo_Target__c>([select id,EUR_CRM_Actual_Volume_Bottles__c,EUR_CRM_Actual_Volume_Displays__c from EUR_CRM_ObjPromo_Target__c where id in: targetIds ]);
        
        //extract all the non-accrued sub actions of secondary them placements visit actions
        if(spThemeVisitActionIds.size() > 0){
            for(EUR_CRM_Visit_Sub_Action__c subAction : [select id, 
                                                            EUR_CRM_Is_Accrued__c,
                                                            EUR_CRM_Number_of_Bottles__c,
                                                            EUR_CRM_Number_of_Cartons__c,
                                                            EUR_CRM_Number_of_Displays__c,
                                                            EUR_CRM_Display_Type__c,
                                                            EUR_CRM_Visit_Action__c
                                                        from EUR_CRM_Visit_Sub_Action__c 
                                                        where 
                                                            EUR_CRM_Visit_Action__c in:spThemeVisitActionIds AND
                                                            EUR_CRM_Is_Accrued__c = false ]){
                
                if(visitActionSubMap.get(subAction.EUR_CRM_Visit_Action__c) == null)
                    visitActionSubMap.put(subAction.EUR_CRM_Visit_Action__c, new List<EUR_CRM_Visit_Sub_Action__c>());
                visitActionSubMap.get(subAction.EUR_CRM_Visit_Action__c).add(subAction);
            }
        }
        for(EUR_CRM_Visit_Action__c visitAction : visitActions){
            try{
            system.debug('@@@ visitAction' + visitAction );
            EUR_CRM_ObjPromo__c objPromo = objPromoMap.get(visitAction.EUR_CRM_ObjPromo__c);

            String recordTypeDevName = recordTypesMap.get(visitAction.recordTypeid).developername;
            system.debug('@@@ visitAction' + visitAction );
            system.debug('@@@ recordTypeDevName ' + recordTypeDevName );
            system.debug('@@@ objPromo ' + objPromo );
            if(objPromo==null)
                continue; 
            DateTime vEndDate = visitAction.EUR_CRM_End_Datetime__c;
            Date visitActionEndDate =  date.newinstance(vEndDate.year(), vEndDate.month(), vEndDate.day());
            system.debug('@@@ visitAction.EUR_CRM_End_Datetime__c >= objPromo.EUR_CRM_Active_Start_Date__c: ' + (visitActionEndDate >= objPromo.EUR_CRM_Active_Start_Date__c));
            system.debug('@@@ visitAction.EUR_CRM_End_Datetime__c <= objPromo.EUR_CRM_Active_End_Date__c: ' + (visitActionEndDate <= objPromo.EUR_CRM_Active_End_Date__c));
            system.debug('@@@ targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c) != null: ' + (targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c) != null));
           

            if(visitAction.EUR_CRM_End_Datetime__c != null &&
               objPromo != null &&
               objPromo.EUR_CRM_Active_Start_Date__c != null &&
               visitActionEndDate >= objPromo.EUR_CRM_Active_Start_Date__c &&
               visitActionEndDate <= objPromo.EUR_CRM_Active_End_Date__c &&
               targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c) != null){
               if(visitAction.EUR_CRM_Is_Successful__c){ 
                    Id rtId = achievementRecordTypes.get(recordTypesMap.get(visitAction.recordtypeid).developername);
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
                }else if(SECONDARY_PLACEMENT_THEME_SELL_IN_QTY == recordTypeDevName){
                    system.debug('@@@ secondary theme placement' );
                    Decimal volBottle = retrieveTotalNumberOfBottles(visitActionSubMap.get(visitAction.id));                    
                    Decimal totalBottle = targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c).EUR_CRM_Actual_Volume_Bottles__c;
                    system.debug('@@@ totalBottle '  +totalBottle );
                    system.debug('@@@ volBottle '  +volBottle );
                    totalBottle = totalBottle == null ? 0 : totalBottle;
                    totalBottle += volBottle;
                    targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c).EUR_CRM_Actual_Volume_Bottles__c = totalBottle;

                }else {
                    //if('EUR_DE_OFF_2nd_Placement_Sell_In_Qty' == recordTypesMap.get(visitAction.recordTypeid).developername){
                    //secondary placement
                    Decimal volBottle = visitAction.EUR_CRM_Sell_In_Volume_Bottles__c == null?0:visitAction.EUR_CRM_Sell_In_Volume_Bottles__c;
                    Decimal totalBottle = targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c).EUR_CRM_Actual_Volume_Bottles__c;
                    system.debug('@@@ not sales drive');                   
                    totalBottle = totalBottle == null ? 0 : totalBottle;
                    totalBottle += volBottle;
                     targetsMap.get(visitAction.EUR_CRM_ObjPromo_Target__c).EUR_CRM_Actual_Volume_Bottles__c = totalBottle;
                 }
                //mark the visit action as 'accrued' except for secondary theme placements
                visitAction.EUR_CRM_Is_Accrued__c = true;
                visitActionsToUpdate.add(visitAction); 
            }
            }catch(Exception e){
                system.debug('@@@ error while traversing the list of visict action: ' + visitAction);
                continue;
            }
        }
        Savepoint sp = Database.setSavepoint();
        try{ 
            system.debug('!! Inserting');
            system.debug('!! Inserting achievementsToInsert ' + achievementsToInsert);
            system.debug('!! Inserting visitActionsToUpdate' + visitActionsToUpdate);
            insert achievementsToInsert;
            update visitActionsToUpdate;
            
            if(targetsMap.size() > 0)
                update targetsMap.values();
            if(visitActionSubMap.size() > 0){
                List<EUR_CRM_Visit_Sub_Action__c> subActionsUpdate = new List<EUR_CRM_Visit_Sub_Action__c>();
               
                for(Id key :visitActionSubMap.keySet()){
                     subActionsUpdate.addAll(visitActionSubMap.get(key));
                }
                for(EUR_CRM_Visit_Sub_Action__c subAction : subActionsUpdate){
                    subAction.EUR_CRM_Is_Accrued__c = true;
                }
                if(subActionsUpdate.size() > 0)
                    update subActionsUpdate;
            }
        }catch(DMLException e){
            system.debug('!! Error in insert/update');
            system.debug(e);
            Database.rollback(sp);
        }
        /*
        Map<Id,EUR_CRM_ObjPromo_Target__c> targetsMap = new Map<id,EUR_CRM_ObjPromo_Target__c>(
        [select id,recordtype.developername, EUR_CRM_Qty_Sell_in_Amount_Bottle__c,EUR_CRM_Qty_Sell_in_Amount_Display__c,EUR_CRM_Target_Volume_Qty__c
            from EUR_CRM_ObjPromo_Target__c
                where id in: visitActionsMap.keySet()]);
        
        for(Id targetKey :targetsMap.keySet()){
            if(targetsMap.get(targetKey).recordtype.developername == TARGET_SR_VOLUME){
                Decimal totalVolume = 0;
                for(Id key2 : targetActionsMap.get(targetKey)){
                    Decimal vol = visitActionsMap.get(key2).EUR_CRM_Sell_in_Volume__c;
                    totalVolume +=  vol == null?0:vol;
                }
                Decimal targetVol = targetsMap.get(targetKey).EUR_CRM_Target_Volume_Qty__c;
                
                if( targetVol != null && targetVol <= totalVolume){
                    //create achievement!!!!
                    EUR_CRM_ObjPromo_Achievement__c achievement = new EUR_CRM_ObjPromo_Achievement__c(
                        EUR_CRM_ObjPromo_Target__c = targetKey,
                        EUR_CRM_ObjPromo__c = targetsMap.get(targetKey).EUR_CRM_ObjPromo__c
                    );
                    achievementsToInsert.add(achievement);
                }               
            }
        }
        */
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