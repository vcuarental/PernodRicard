global class EUR_CRM_MassUpdatePRSFinalResultBatch implements Database.Batchable<sObject>{
    String countryCode;
    String potential;
    
    /*****************************************************************************************
    *   Constructor. Sets the country Code to retrieve PROS Segmentation from that country alone
    *   @param: 
    *        CountryCode [String] : The 2 letter abbreviation code of the country 
    *****************************************************************************************/
    global EUR_CRM_MassUpdatePRSFinalResultBatch(String countryCode, String potential){
        System.debug('@@EUR_CRM_MassUpdatePRSFinalResultBatch');
        this.countryCode = countryCode;
        this.potential = potential;
    }
    
    /*****************************************************************************************
    *   Batch start function
    *   Queries all PROS Segmentation records with updated Image Level Threshold in their associated Group Outlet Type
    *   @param: 
    *        BC [BatchContext] : Fed automatically, this function is not called explicitly
    *****************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC){  
        System.debug('@@ Start EUR_CRM_MassUpdatePRSFinalResultBatch');
        // Selects PROS Segmentation records which Image Thresholds', in their Group Outlet Types, had their weight change
        //  AND belong to the specified country 
        String query =  'select id, EUR_CRM_PRS_BrandBuildPot_TotalAnswWgt__c, EUR_CRM_PRS_BusinessPot_TotalAnswWgt__c,' + 
                        'EUR_CRM_PRS_ImageLevel_TotalAnswWgt__c, EUR_CRM_PRS_VolumePot_TotalAnswWgt__c, ' + 
                        'EUR_CRM_PRS_Group_Outlet_Type__c from EUR_CRM_PRS_Segmentation__c ' + 
                        'where EUR_CRM_PRS_Group_Outlet_Type__c in (select EUR_CRM_PRS_Group_Outlet_Type__c from EUR_CRM_PRS_Seg_Aspect_Criteria__c where EUR_CRM_Is_Weight_Changed__c = true) ';
        if(countryCode!= null){
             query +=' AND EUR_CRM_PRS_Segmentation__c.eur_crm_country_code__c =\'' + countryCode+'\'';
        }

        System.debug(query);
        return Database.getQueryLocator(query);
    }
    
  
    /*****************************************************************************************
    *   Batch execute function
    *   Calls the main logic
    *   @param: 
    *        BC [BatchContext] : Fed automatically, this function is not called explicitly
    *        Scope [List<sObject>] : Fed autimatically, the list of sObject retrieved in the start function
    *****************************************************************************************/
    global void execute(Database.BatchableContext BC, List<sObject>scope){
        // TODO
        System.debug('@@execute - BC   :' + BC);
        System.debug('@@Scope:' + scope);
        processFinalResultCriteria((List<EUR_CRM_PRS_Segmentation__c>) scope);
    }
   
    /*****************************************************************************************
    *   Batch finish function
    *   Sends an email notification to the user who started the batch on its completion
    *   @param:
    *        BC [BatchContext] : Fed automatically, this function is not called explicitly   
    *****************************************************************************************/
    global void finish(Database.BatchableContext BC){
        System.debug('@@finish - BC   :' + BC);
        EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), BC.getJobId(), new String[] {});
    }
    
    
    /*****************************************************************************************
    *   Updates the PROS Segmentation records' Image Level Threshold according to the updated thresholds in their Group Outlet Types
    *   Also sets the EUR_CRM_Is_Weight_Changed__c flag of the Image Level Thresholds that were updated to false before updating
    *   @param: 
    *        prSegmentations [List<EUR_CRM_PRS_Segmentation__c>] : List of PROS Segmentations to be updated as specified by the scope in the execute function
    *****************************************************************************************/
    public void processFinalResultCriteria(List<EUR_CRM_PRS_Segmentation__c> prSegmentations){
        System.debug('@@processFinalResultCriteria');
        // Retrieve the Group Outlet Type Ids of all the PROS segmentations that were queried 
        Set<Id> groupOutletSet = new Set<Id>();
        // Initialize a Set of Pros Segmentation Id to requery Pros Segmentation
        Set<Id> prSegmentationIdSet = new Set<Id>();
        
        List<EUR_CRM_Account__c> updateAccount = new List<EUR_CRM_Account__c>();
        
        for(EUR_CRM_PRS_Segmentation__c pros : prSegmentations){
            groupOutletSet.add(pros.EUR_CRM_PRS_Group_Outlet_Type__c);
            prSegmentationIdSet.add(pros.Id);
        }

        System.debug('@@groupOutletSet:' + groupOutletSet);
        System.debug('@@prSegmentationIdSet:' +prSegmentationIdSet);

        // Retrieve a new list of Pros Segmentation to reflect updated roll up summary fields
        prSegmentations = [ SELECT Id, EUR_CRM_PRS_Group_Outlet_Type__c, 
                            EUR_CRM_PRS_BusinessPot_TotalAnswWgt__c, EUR_CRM_PRS_BrandBuildPot_TotalAnswWgt__c, 
                            EUR_CRM_PRS_ImageLevel_TotalAnswWgt__c,EUR_CRM_PRS_VolumePot_TotalAnswWgt__c,  EUR_CRM_Account__c
                            FROM EUR_CRM_PRS_Segmentation__c
                            WHERE Id IN: prSegmentationIdSet];
        
        Set<Id> accountIds = new Set<Id>();
        for(EUR_CRM_PRS_Segmentation__c prSeg : prSegmentations)
        {
            accountIds.add(prSeg.EUR_CRM_Account__c);
        }
        
        Map<Id,EUR_CRM_Account__c> accounts = new Map<Id,EUR_CRM_Account__c>([SELECT Id,EUR_CRM_Is_PRS_Dimensions_Forced__c FROM EUR_CRM_Account__c Where Id IN: accountIds]);
		System.debug('@@accountIsForceedInfo:' + accounts);
        // A map of each Group Outlet Type and all its Image Level Thresholds
        Map<Id,List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>> groupOutletTypePRSFinalResultCriteriaMap = new Map<Id,List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>>();
        // The list of Image Level Thresholds to be updated
        List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> updatePRSFinalResultCriteria = new List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>();
        
        String CriteriaFilter;
        if(this.potential == 'BrandBuilding') {
            System.debug('@@BBP Filter Criteria:');
            //CriteriaFilter = '012L00000009J9WIAU';
            CriteriaFilter = 'EUR_PRS_Segmentation_Aspect_Criteria_BBP';
        } else if(this.potential == 'BusinessPotential'){
            System.debug('@@BP Filter Criteria:');
            //CriteriaFilter = '012L00000009J9bIAE';
            CriteriaFilter = 'EUR_PRS_Segmentation_Aspect_Criteria_BP';
        } else if(this.potential == 'ImageLevel'){
            System.debug('@@IL Filter Criteria:');
            //CriteriaFilter = '012L00000009J9bIAE';
            CriteriaFilter = 'EUR_PRS_Segmentation_Aspect_Criteria_Image_Level';
        } else if(this.potential == 'VolumePotential'){
            System.debug('@@VL Filter Criteria:');
            //CriteriaFilter = '012L00000009J9bIAE';
            CriteriaFilter = 'EUR_PRS_Segmentation_Aspect_Criteria_Volume_Potential';
        } else{
            System.debug('@@Filter Criteria Not Specify!');
        }

        //List<RecordType> RT = [SELECT Id,DeveloperName FROM RecordType 
        //                       WHERE SObjectType = 'EUR_CRM_PRS_Seg_Aspect_Criteria__c'
        //                       AND DeveloperName = :CriteriaFilter];
        
        //System.debug('@@RecordTypeFilter:' + RT);
        
        // Population of the map
        // The SOQL queries for all the Thresholds for each Group Outlet Type
        for(EUR_CRM_PRS_Seg_Aspect_Criteria__c finalResultCriteria : [select id,EUR_CRM_Is_Weight_Changed__c ,EUR_CRM_Brand_Building_Potential__c,
                                                                        EUR_CRM_Business_Potential__c,EUR_CRM_Image_Level__c,EUR_CRM_Volume_Potential__c,
                                                                        EUR_CRM_PRS_Group_Outlet_Type__c,EUR_CRM_Minimum_Weight__c, RecordType.DeveloperName
                                                                        from EUR_CRM_PRS_Seg_Aspect_Criteria__c
                                                                        where EUR_CRM_PRS_Seg_Aspect_Criteria__c.RecordType.DeveloperName = :CriteriaFilter AND EUR_CRM_PRS_Group_Outlet_Type__c in : groupOutletSet]){

            System.debug('@@finalResultCriteria:' + finalResultCriteria);



            //  Initialize the Image Level Threshold Lists in the map
            if(groupOutletTypePRSFinalResultCriteriaMap.get(finalResultCriteria.EUR_CRM_PRS_Group_Outlet_Type__c) == null)
            {
                groupOutletTypePRSFinalResultCriteriaMap.put(finalResultCriteria.EUR_CRM_PRS_Group_Outlet_Type__c, new List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>());
            }
            // adds each threshold to the list of thresholds in the map under the respective outlet group
            groupOutletTypePRSFinalResultCriteriaMap.get(finalResultCriteria.EUR_CRM_PRS_Group_Outlet_Type__c).add(finalResultCriteria);
            
            // If the threshold has been updated before running this batch, set the Changed flagged to false
            if(finalResultCriteria.EUR_CRM_Is_Weight_Changed__c)
            {
                updatePRSFinalResultCriteria.add (new EUR_CRM_PRS_Seg_Aspect_Criteria__c (id = finalResultCriteria.id,  EUR_CRM_Is_Weight_Changed__c = false));
            }
        }

        System.debug('@@groupOutletTypePRSFinalResultCriteriaMap:' + groupOutletTypePRSFinalResultCriteriaMap);
        System.debug('@@updatePRSFinalResultCriteria:' + updatePRSFinalResultCriteria);

		//List of Segmentation to be update
		List<EUR_CRM_PRS_Segmentation__c> updatePRSegmentations = new List<EUR_CRM_PRS_Segmentation__c>();
        //List of Account to be update
        List<EUR_CRM_Account__c> updateAccounts = new List<EUR_CRM_Account__c>();
        
        if(this.potential == 'BrandBuilding') {
            System.debug('@@BBP Process...');
            for(EUR_CRM_PRS_Segmentation__c pros : prSegmentations){
                // Get the new approperiate Image Level Thresholds for each PROS Segmentation to be updated
                EUR_CRM_PRS_Seg_Aspect_Criteria__c threshold = retrieveFinalResultCriteria(
                    pros.EUR_CRM_PRS_BrandBuildPot_TotalAnswWgt__c,
                    groupOutletTypePRSFinalResultCriteriaMap.get(pros.EUR_CRM_PRS_Group_Outlet_Type__c),
                    'EUR_CRM_Brand_Building_Potential__c');
                if(threshold == null) {
                    continue;
                }
                updatePRSegmentations.add(new EUR_CRM_PRS_Segmentation__c(
                    id = pros.id,
                    EUR_CRM_BrandBuilding_Potential_Criteria__c = threshold.id,
                    EUR_CRM_Brand_Building_Potential__c = threshold.EUR_CRM_Brand_Building_Potential__c
                ));
                
                if(accounts.get(pros.EUR_CRM_Account__c).EUR_CRM_Is_PRS_Dimensions_Forced__c == false)
                {
                    updateAccounts.add(new EUR_CRM_Account__c(
                        id = pros.EUR_CRM_Account__c,
                        EUR_CRM_Brand_Building_Potential__c = threshold.EUR_CRM_Brand_Building_Potential__c
                    ));   
                }

            }
        } else if(this.potential == 'BusinessPotential') {
            System.debug('@@BP Process...');

            for(EUR_CRM_PRS_Segmentation__c pros : prSegmentations){
                EUR_CRM_PRS_Seg_Aspect_Criteria__c threshold = retrieveFinalResultCriteria(
                    pros.EUR_CRM_PRS_BusinessPot_TotalAnswWgt__c,
                    groupOutletTypePRSFinalResultCriteriaMap.get(pros.EUR_CRM_PRS_Group_Outlet_Type__c),
                    'EUR_CRM_Business_Potential__c');

                System.debug('@@threshold:' + threshold);

                if(threshold == null) {
                    continue;
                }
                updatePRSegmentations.add(new EUR_CRM_PRS_Segmentation__c(
                    id = pros.id,
                    EUR_CRM_Business_Potential_Criteria__c = threshold.id,
                    EUR_CRM_Business_Potential__c = threshold.EUR_CRM_Business_Potential__c
                ));
                if(accounts.get(pros.EUR_CRM_Account__c).EUR_CRM_Is_PRS_Dimensions_Forced__c == false)
                {
                    updateAccounts.add(new EUR_CRM_Account__c(
                        id = pros.EUR_CRM_Account__c,
                        EUR_CRM_Business_Potential__c = threshold.EUR_CRM_Business_Potential__c
                    ));
                }
            }
        } else if(this.potential == 'ImageLevel') {
            System.debug('@@IL Process...');

            for(EUR_CRM_PRS_Segmentation__c pros : prSegmentations){
                EUR_CRM_PRS_Seg_Aspect_Criteria__c threshold = retrieveFinalResultCriteria(
                    pros.EUR_CRM_PRS_ImageLevel_TotalAnswWgt__c,
                    groupOutletTypePRSFinalResultCriteriaMap.get(pros.EUR_CRM_PRS_Group_Outlet_Type__c),
                    'EUR_CRM_Image_Level__c');

                System.debug('@@threshold:' + threshold);

                if(threshold == null) {
                    continue;
                }
                updatePRSegmentations.add(new EUR_CRM_PRS_Segmentation__c(
                    id = pros.id,
                    EUR_CRM_Image_Level_Criteria__c = threshold.id,
                    EUR_CRM_Image_Level__c = threshold.EUR_CRM_Image_Level__c
                ));
                if(accounts.get(pros.EUR_CRM_Account__c).EUR_CRM_Is_PRS_Dimensions_Forced__c == false)
                {
                    updateAccounts.add(new EUR_CRM_Account__c(
                        id = pros.EUR_CRM_Account__c,
                        EUR_CRM_PRS_Image_Level__c = threshold.EUR_CRM_Image_Level__c
                    ));
                }
            }
        } else if(this.potential == 'VolumePotential') {
            System.debug('@@VP Process...');

            for(EUR_CRM_PRS_Segmentation__c pros : prSegmentations){
                EUR_CRM_PRS_Seg_Aspect_Criteria__c threshold = retrieveFinalResultCriteria(
                    pros.EUR_CRM_PRS_VolumePot_TotalAnswWgt__c,
                    groupOutletTypePRSFinalResultCriteriaMap.get(pros.EUR_CRM_PRS_Group_Outlet_Type__c),
                    'EUR_CRM_Volume_Potential__c');

                System.debug('@@threshold:' + threshold);

                if(threshold == null) {
                    continue;
                }
                updatePRSegmentations.add(new EUR_CRM_PRS_Segmentation__c(
                    id = pros.id,
                    EUR_CRM_Volume_Potential_Criteria__c = threshold.id,
                    EUR_CRM_Volume_Potential__c = threshold.EUR_CRM_Volume_Potential__c
                ));
                if(accounts.get(pros.EUR_CRM_Account__c).EUR_CRM_Is_PRS_Dimensions_Forced__c == false)
                {
                    updateAccounts.add(new EUR_CRM_Account__c(
                        id = pros.EUR_CRM_Account__c,
                        EUR_CRM_PRS_Volume_Potential__c = threshold.EUR_CRM_Volume_Potential__c
                    ));
                }
            }
        }
        

        
        
        System.debug('@@Updated PROS :' + updatePRSegmentations);
        System.debug('@@Updated Image Level Threshold :' + updatePRSFinalResultCriteria);
        System.debug('@@Updated account:'+ updateAccounts);
        // Attempt to update. Roll back in case of any record failure 
        Savepoint sp = Database.setSavepoint();
        try{
            EUR_CRM_CommonRoutine.dmlWithPartialSuccess('update',updatePRSegmentations);
            EUR_CRM_CommonRoutine.dmlWithPartialSuccess('update',updatePRSFinalResultCriteria);
            EUR_CRM_CommonRoutine.dmlWithPartialSuccess('update',updateAccounts);
        }catch(Exception e){
            System.debug('Rolling back all changes');
            System.debug('@@updatePRSegmentations:' + updatePRSegmentations);
            System.debug('@@updatePRSFinalResultCriteria:' + updatePRSFinalResultCriteria);
            System.debug('@@updateAccount:' + updateAccounts);
            Database.rollback(sp);
        }
    }
    
    /*****************************************************************************************
    *   Returns the approperiate threshold for that a PROS Segmentation according to its total Brand Building / Business potential scores
    *   @params: 
    *            weight [Decimal] : The total volume score of the Account, as currently in their PROS segmentation record 
    *            finalResultCriterias [List<EUR_CRM_PRS_Seg_Aspect_Criteria__c>] : The list of all thresholds associated with the Account's Group Outlet Type
    *   @returns: 
    *            tempThreshold [EUR_CRM_PRS_Seg_Aspect_Criteria__c] : The new approperiate threshold according to the weight 
    *****************************************************************************************/
    public EUR_CRM_PRS_Seg_Aspect_Criteria__c retrieveFinalResultCriteria(Decimal weight, List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> finalResultCriterias, String fieldName){
        System.debug('@@retrieveFinalResultCriteria');
        Decimal tempWeight = 0;
        EUR_CRM_PRS_Seg_Aspect_Criteria__c tempThreshold = null;
        for(EUR_CRM_PRS_Seg_Aspect_Criteria__c finalResultCriteria  : finalResultCriterias){            
            // Checks the PROS Image Level total score falls within which Image Level Threshold and returns it
            system.debug('@@weight:' + weight + ' vs EUR_CRM_Minimum_Weight:' + finalResultCriteria.EUR_CRM_Minimum_Weight__c + ' vs tempWeight' + tempWeight);
            if(weight >= finalResultCriteria.EUR_CRM_Minimum_Weight__c && tempWeight<= finalResultCriteria.EUR_CRM_Minimum_Weight__c && finalResultCriteria.get(fieldName) != null){
                tempWeight= finalResultCriteria.EUR_CRM_Minimum_Weight__c;
                tempThreshold = finalResultCriteria;
                system.debug('@@weight updated:' + tempThreshold);
            }
        } 
        return tempThreshold;
    }
}