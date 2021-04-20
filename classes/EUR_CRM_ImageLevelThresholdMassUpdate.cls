/*****************************************************************************************
* 	EUR_CRM_ImageLevelThresholdMassUpdate Batch Job
*
*	Updates the Image Level Threshold values inside PROS Segmentations
*	if the Image Level Thresholds in the corrosponding Group Outlet Type were updated
*****************************************************************************************/

global class EUR_CRM_ImageLevelThresholdMassUpdate implements Database.Batchable<sObject>{  
    String countryCode;
    
    /*****************************************************************************************
	*	Constructor. Sets the country Code to retrieve PROS Segmentation from that country alone
	*	@param: 
    *        CountryCode [String] : The 2 letter abbreviation code of the country 
	*****************************************************************************************/

    global EUR_CRM_ImageLevelThresholdMassUpdate (String countryCode){
        this.countryCode = countryCode;
    }
    
    /*****************************************************************************************
	*	Batch start function
	*	Queries all PROS Segmentation records with updated Image Level Threshold in their associated Group Outlet Type
	*	@param: 
    *        BC [BatchContext] : Fed automatically, this function is not called explicitly
	*****************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC){  
        // Selects PROS Segmentation records which Image Thresholds', in their Group Outlet Types, had their weight change
        //  AND belong to the specified country 
        String query = 'select id, EUR_CRM_Total_Image_Level_Weight__c, EUR_CRM_Total_Volume_Weight__c, EUR_CRM_Group_Outlet_Type__c from EUR_CRM_Pros_Segmentation__c ' + 
                            'where EUR_CRM_Group_Outlet_Type__c in (select EUR_CRM_Group_Outlet_Type__c from EUR_CRM_Image_Level_Threshold__c where EUR_CRM_Is_Weight_Changed__c = true) ';
        if(countryCode!= null){
             query +=' AND EUR_CRM_Pros_Segmentation__c.eur_crm_country_code__c =\'' + countryCode+'\'';
        }
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
        processImageLevelThreshold((List<EUR_CRM_Pros_Segmentation__c>) scope);
    }
   
    /*****************************************************************************************
	*	Batch finish function
	*	Sends an email notification to the user who started the batch on its completion
	*	@param:
    *        BC [BatchContext] : Fed automatically, this function is not called explicitly   
	*****************************************************************************************/
    global void finish(Database.BatchableContext BC){
        AsyncApexJob apexjob = [Select Id From AsyncApexJob WHERE Id =:BC.getJobId()];
        EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(), apexjob.id, new String[] {});
    }
    
    
    /*****************************************************************************************
	*	Updates the PROS Segmentation records' Image Level Threshold according to the updated thresholds in their Group Outlet Types
	*	Also sets the EUR_CRM_Is_Weight_Changed__c flag of the Image Level Thresholds that were updated to false before updating
	*	@param: 
    *        prosSegmentations [List<EUR_CRM_Pros_Segmentation__c>] : List of PROS Segmentations to be updated as specified by the scope in the execute function
	*****************************************************************************************/
    public static void processImageLevelThreshold(List<EUR_CRM_Pros_Segmentation__c> prosSegmentations){
		// Retrieve the Group Outlet Type Ids of all the PROS segmentations that were queried 
        Set<Id> groupOutletSet = new Set<Id>();
        // Initialize a Set of Pros Segmentation Id to requery Pros Segmentation
        Set<Id> prosSegmentationIdSet = new Set<Id>();
        for(EUR_CRM_Pros_Segmentation__c pros : prosSegmentations){
            groupOutletSet.add(pros.EUR_CRM_Group_Outlet_Type__c);
            prosSegmentationIdSet.add(pros.Id);
        }
        
        // Retrieve a new list of Pros Segmentation to reflect updated roll up summary fields
        prosSegmentations = [SELECT Id, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Total_Image_Level_Weight__c, EUR_CRM_Total_Volume_Weight__c
                            FROM EUR_CRM_Pros_Segmentation__c
                            WHERE Id IN: prosSegmentationIdSet];
                                    
        // A map of each Group Outlet Type and all its Image Level Thresholds
        Map<Id,List<EUR_CRM_Image_Level_Threshold__c>> groupOutletImageLevelThresholds = new Map<Id,List<EUR_CRM_Image_Level_Threshold__c>>();
        // The list of Image Level Thresholds to be updated
        List<EUR_CRM_Image_Level_Threshold__c> imageLevelThresholdsUpdated = new List<EUR_CRM_Image_Level_Threshold__c>();
        
        // Population of the map
        // The SOQL queries for all the Thresholds for each Group Outlet Type
        for(EUR_CRM_Image_Level_Threshold__c imageLevelThreshold : [select id,EUR_CRM_Is_Weight_Changed__c ,EUR_CRM_Image_Level__c,EUR_CRM_Group_Outlet_Type__c,EUR_CRM_Min_Weight__c from EUR_CRM_Image_Level_Threshold__c where EUR_CRM_Group_Outlet_Type__c in : groupOutletSet]){
            //	Initialize the Image Level Threshold Lists in the map
            if(groupOutletImageLevelThresholds.get(imageLevelThreshold.EUR_CRM_Group_Outlet_Type__c) == null)
            {
                groupOutletImageLevelThresholds.put(imageLevelThreshold.EUR_CRM_Group_Outlet_Type__c, new List<EUR_CRM_Image_Level_Threshold__c>());
            }
            // adds each threshold to the list of thresholds in the map under the respective outlet group
            groupOutletImageLevelThresholds.get(imageLevelThreshold.EUR_CRM_Group_Outlet_Type__c).add(imageLevelThreshold);
            
            // If the threshold has been updated before running this batch, set the Changed flagged to false
            if(imageLevelThreshold.EUR_CRM_Is_Weight_Changed__c)
            {
                imageLevelThresholdsUpdated.add (new EUR_CRM_Image_Level_Threshold__c (id = imageLevelThreshold.id,  EUR_CRM_Is_Weight_Changed__c = false));
            }
        }
        
        List<EUR_CRM_Pros_Segmentation__c> prosUpdated = new List<EUR_CRM_Pros_Segmentation__c>();
        for(EUR_CRM_Pros_Segmentation__c pros : prosSegmentations){
        	// Get the new approperiate Image Level Thresholds for each PROS Segmentation to be updated
            EUR_CRM_Image_Level_Threshold__c threshold = retriveImageLevelThreshold(pros.EUR_CRM_Total_Image_Level_Weight__c, groupOutletImageLevelThresholds.get(pros.EUR_CRM_Group_Outlet_Type__c));
            if(threshold == null)
            {
            	continue;
            }
            prosUpdated.add(new EUR_CRM_Pros_Segmentation__c(id = pros.id, EUR_CRM_Image_Level_Threshold__c = threshold.id , EUR_CRM_Image_Level__c = threshold.EUR_CRM_Image_Level__c ));
        }
        
        System.debug('Updated PROS ' + prosUpdated);
        System.debug('Updated Image Level Threshold' + imageLevelThresholdsUpdated);
        
        // Attempt to update. Roll back in case of any record failure 
        Savepoint sp = Database.setSavepoint();
        try{
            EUR_CRM_CommonRoutine.dmlWithPartialSuccess('update',prosUpdated);
            EUR_CRM_CommonRoutine.dmlWithPartialSuccess('update',imageLevelThresholdsUpdated);
        }catch(Exception e){
            System.debug('Rolling back all changes');
            System.debug(prosUpdated);
            System.debug(imageLevelThresholdsUpdated);
            Database.rollback(sp);
        }
    }
    
    /*****************************************************************************************
    *   Returns the approperiate threshold for that a PROS Segmentation according to its total Image Level score
    *   @params: 
    *            weight [Decimal] : The total volume score of the Account, as currently in their PROS segmentation record 
    *            imageLevelThresholds [List<EUR_CRM_Image_Level_Threshold__c>] : The list of all thresholds associated with the Account's Group Outlet Type
    *   @returns: 
    *            tempThreshold [EUR_CRM_Image_Level_Threshold__c] : The new approperiate threshold according to the weight 
    *****************************************************************************************/
    public static EUR_CRM_Image_Level_Threshold__c retriveImageLevelThreshold(Decimal weight, List<EUR_CRM_Image_Level_Threshold__c> imageLevelThresholds){
        Decimal tempWeight = 0;
        EUR_CRM_Image_Level_Threshold__c tempThreshold = null;
        for(EUR_CRM_Image_Level_Threshold__c imageLevelThreshold  : imageLevelThresholds){
        	// Checks the PROS Image Level total score falls within which Image Level Threshold and returns it
            if(weight >= imageLevelThreshold.EUR_CRM_Min_Weight__c && tempWeight<= imageLevelThreshold.EUR_CRM_Min_Weight__c){
                tempWeight= imageLevelThreshold.EUR_CRM_Min_Weight__c;
                tempThreshold = imageLevelThreshold;
            }
        } 
        return tempThreshold;
    }
}