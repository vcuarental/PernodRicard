global class EUR_CRM_MassUpdatePRSQuestionsBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    private Double answerWeight;
    private List<EUR_CRM_PRS_Group_Outlet_Type__c> groupOutletTypeInfoList;
    private List<EUR_CRM_PRS_Answer__c> newBrandBuildingPotential;  
    
    public Set<Id> prsQuestionsGOTypeMappingIds;
    public Map<Id, EUR_CRM_PRS_Segmentation__c> prSegIdMap;
    
    public List<EUR_CRM_PRS_Answer__c> updatePRSUserAnswers;

    /*public List<EUR_CRM_PRS_Answer__c> updatePRSUserAnswersBBP;
    public List<EUR_CRM_PRS_Answer__c> updatePRSUserAnswersBP;

    public List<EUR_CRM_PRS_Answer__c> updatePRSUserAnswersIL; 
    public List<EUR_CRM_PRS_Answer__c> updatePRSUserAnswersVP; */

    String countryCode; 
    public String potential;
    public String questionSetRecordType;
    
    global List<EUR_CRM_PRS_Question_Set__c> prsQuestionGOTypeMappings;
    global List<EUR_CRM_PRS_Question__c> prsQuestionsList;
    

    /*****************************************************************************************
    *   Constructor. Sets the country Code to retrieve PR Segmentation from that country alone
    *   and initializes the arrays
    *   @param: 
    *        CountryCode [String] : The 2 letter abbreviation code of the country 
    *****************************************************************************************/
    global EUR_CRM_MassUpdatePRSQuestionsBatch (String potential){
        this.potential = potential;
        prsQuestionsGOTypeMappingIds = new Set<Id>();
        newBrandBuildingPotential = new List<EUR_CRM_PRS_Answer__c>();
        updatePRSUserAnswers = new List<EUR_CRM_PRS_Answer__c>();

        if(potential == 'BrandBuilding'){
            questionSetRecordType = '%Brand_Building_Potential%';
        }else if(potential == 'BusinessPotential'){
            questionSetRecordType = '%Business_Potential%';
        }else if(potential == 'ImageLevel'){
            questionSetRecordType = '%Image_Level%';
        }else if(potential == 'VolumePotential'){
            questionSetRecordType = '%Volume_Potential%';
        }
    }
    
    /*****************************************************************************************
    *   Second Constructor. Sets the country Code to retrieve PR Segmentation from that country alone
    *   as well as the criteria set (whether BP/BBP/IL/VP)
    *   @param: 
    *        potential [String] : whether BP/BBP/IL/VP, depending on the button clicked
    *        CountryCode [String] : The 2 letter abbreviation code of the country 
    *****************************************************************************************/
    global EUR_CRM_MassUpdatePRSQuestionsBatch (String potential, String countryCode){
        this.potential = potential;
        prsQuestionsGOTypeMappingIds = new Set<Id>();
        newBrandBuildingPotential = new List<EUR_CRM_PRS_Answer__c>();
        updatePRSUserAnswers = new List<EUR_CRM_PRS_Answer__c>();
        this.countryCode = countryCode;

        if(potential == 'BrandBuilding'){
            questionSetRecordType = '%Brand_Building_Potential%';
        }else if(potential == 'BusinessPotential'){
            questionSetRecordType = '%Business_Potential%';
        }else if(potential == 'ImageLevel'){
            questionSetRecordType = '%Image_Level%';
        }else if(potential == 'VolumePotential'){
            questionSetRecordType = '%Volume_Potential%';
        }
    }
    
    /*****************************************************************************************
    *   Batch start function
    *   Queries all criteria thresholds records with updated criterias depending on the specified potential
    *   @param: 
    *        BC [BatchContext] : Fed automatically, this function is not called explicitly
    *****************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC){  
        String query1 = 'SELECT Id, EUR_CRM_PRS_Question_Set__c, EUR_CRM_Weight_Has_Changed__c FROM EUR_CRM_PRS_Question__c ' + 
                            'WHERE EUR_CRM_Weight_Has_Changed__c = true AND EUR_CRM_PRS_Question_Set__r.RecordType.DeveloperName LIKE :questionSetRecordType';
        if(countryCode!= null){
             query1 +=' AND EUR_CRM_PRS_Question_Set__r.eur_crm_country_code__c =\'' + countryCode+'\'';
        }

        system.debug('***prsQuestionsQuery: ' + query1);
        
        List<EUR_CRM_PRS_Question__c> prsQuestions = Database.query(query1);
        
        system.debug('***prsQuestions: ' + prsQuestions);
        
        prSegIdMap = new Map<Id, EUR_CRM_PRS_Segmentation__c>();
        groupOutletTypeInfoList = new List<EUR_CRM_PRS_Group_Outlet_Type__c>();
        updatePRSUserAnswers = new List<EUR_CRM_PRS_Answer__c>();
        /*updatePRSUserAnswersBBP = new List<EUR_CRM_PRS_Answer__c>();
        updatePRSUserAnswersBP = new List<EUR_CRM_PRS_Answer__c>();*/

        Set<Id> grpOutletIds = new Set<Id>();
        prsQuestionGOTypeMappings = new List<EUR_CRM_PRS_Question_Set__c>();
        prsQuestionsList = new List<EUR_CRM_PRS_Question__c>();
        
        // Create a set of all Questions - GOType Mapping Ids
        // AND a global list of all Questions
        for(EUR_CRM_PRS_Question__c ct : prsQuestions){
            prsQuestionsGOTypeMappingIds.add(ct.EUR_CRM_PRS_Question_Set__c);
            prsQuestionsList.add(ct);
        }
        
        // If criterias were updated retrieve the group outlet types 
        if(prsQuestionsGOTypeMappingIds.size() > 0){
        	System.debug(prsQuestionsGOTypeMappingIds);

            prsQuestionGOTypeMappings = [SELECT Id, RecordType.DeveloperName FROM EUR_CRM_PRS_Question_Set__c WHERE Id IN: prsQuestionsGOTypeMappingIds];
            system.debug('***prsQuestionGOTypeMappings' + prsQuestionGOTypeMappings);

            if(potential == 'BrandBuilding'){
                groupOutletTypeInfoList = [SELECT Id, EUR_CRM_Group_Outlet_Type_Name__c, EUR_CRM_BrandBuildPotQuestionSet__r.Id 
                                            FROM EUR_CRM_PRS_Group_Outlet_Type__c WHERE EUR_CRM_BrandBuildPotQuestionSet__r.Id IN :prsQuestionsGOTypeMappingIds];
            }else if(potential == 'BusinessPotential'){
                groupOutletTypeInfoList = [SELECT Id, EUR_CRM_Group_Outlet_Type_Name__c, EUR_CRM_BusinessPotentialQuestionSet__r.Id 
                                            FROM EUR_CRM_PRS_Group_Outlet_Type__c WHERE EUR_CRM_BusinessPotentialQuestionSet__r.Id IN :prsQuestionsGOTypeMappingIds];
            }else if(potential == 'ImageLevel'){
                groupOutletTypeInfoList = [SELECT Id, EUR_CRM_Group_Outlet_Type_Name__c, EUR_CRM_Image_Level_Question_Set__r.Id 
                                            FROM EUR_CRM_PRS_Group_Outlet_Type__c WHERE EUR_CRM_Image_Level_Question_Set__r.Id IN :prsQuestionsGOTypeMappingIds];
            }else if(potential == 'VolumePotential'){
                groupOutletTypeInfoList = [SELECT Id, EUR_CRM_Group_Outlet_Type_Name__c, EUR_CRM_Volume_Potential_Question_Set__r.Id 
                                            FROM EUR_CRM_PRS_Group_Outlet_Type__c WHERE EUR_CRM_Volume_Potential_Question_Set__r.Id IN :prsQuestionsGOTypeMappingIds];
            }
        
            System.debug(groupOutletTypeInfoList);
        }
        
        if(groupOutletTypeInfoList.size() > 0){
            // Get unique Ids of Group Outlet Types
            for (EUR_CRM_PRS_Group_Outlet_Type__c got : groupOutletTypeInfoList){
                grpOutletIds.add(got.Id);
            }

            system.debug('***grpOutletIds ' + grpOutletIds.size() + '  ' + grpOutletIds);
        }
        
        // Retrieve all the PR Segmentations to be updated
        String query = 'SELECT Id, EUR_CRM_PRS_Group_Outlet_Type__c ' + 
        				'FROM EUR_CRM_PRS_Segmentation__c  ' + 
						'WHERE EUR_CRM_PRS_Group_Outlet_Type__c IN :grpOutletIds';
			
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
        updatePRSQuestionGOTypeMapping((List<EUR_CRM_PRS_Segmentation__c>) scope);
    }


    /*****************************************************************************************
    *   Batch finish function
    *   Updates the list of Criteria Sets AND Criteria Thresholds
    *   Then sends an email notification to the user who started the batch on its completion
    *   @param:
    *        BC [BatchContext] : Fed automatically, this function is not called explicitly   
    *****************************************************************************************/   
    global void finish(Database.BatchableContext BC){
		// TODO: Add Error Handling for Null Pointer exceptions

        //update level Criteria Set
        for (EUR_CRM_PRS_Question_Set__c cs : prsQuestionGOTypeMappings){
            cs.EUR_CRM_Last_Mass_Update_Date__c = Datetime.now();
        }
        update prsQuestionGOTypeMappings;
        
        // Unchecks isChanged flagged for criteria thresholds
        for(EUR_CRM_PRS_Question__c ct : prsQuestionsList){
            ct.EUR_CRM_Weight_Has_Changed__c = false;
        }
        update prsQuestionsList;
    	
        EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(),BC.getJobId(), new String[] {});
    }

    /*****************************************************************************************
    *  
    *   @param: 
    *        prSegList [List<EUR_CRM_PRS_Segmentation__c>] : List of PR Segmentations to be updated as specified by the scope in the execute function
    *****************************************************************************************/
    public void updatePRSQuestionGOTypeMapping(List<EUR_CRM_PRS_Segmentation__c> prSegList){
        
        // Populate the PR Segmentation map
        if (prSegList.size() > 0){
            for (EUR_CRM_PRS_Segmentation__c eupros : prSegList){
                prSegIdMap.put(eupros.Id, eupros);
            }
            system.debug('***prSegIdMap ' + prSegIdMap.size() + '  ' + prSegIdMap);
        }
        
        // Call the respective calculation functions
        if (groupOutletTypeInfoList.size() > 0){

            /*if(potential == '%Brand_Building%' || potential == '%Business%'){
                calculateBoolean();
                calculateInteger();
                calculatePicklist();
                calculateCurrency();
                calculateText();
            }*/

            calculateBoolean();
            calculateInteger();
            calculatePicklist();
            calculateCurrency();
            calculateText();

            //Update Image/Volume Pros
            if(potential == 'BrandBuilding'){
                system.debug('***updatePRSUserAnswersBBP.size(): ' + updatePRSUserAnswers.size());
                
                if(updatePRSUserAnswers.size() > 0){
                    
                    // Remove duplicates from list of pros image level
                    Set<EUR_CRM_PRS_Answer__c> tempBBPUserAnswerSet = new Set<EUR_CRM_PRS_Answer__c>();
                    tempBBPUserAnswerSet.addAll(updatePRSUserAnswers);
                    List<EUR_CRM_PRS_Answer__c> updatePRSUserAnswersBBPNoDuplication = new List<EUR_CRM_PRS_Answer__c>();
                    updatePRSUserAnswersBBPNoDuplication.addAll(tempBBPUserAnswerSet);
                    
                    System.debug(updatePRSUserAnswersBBPNoDuplication);
                    
                    try{
                        // Update PR Segmentation and Image Level Threshold (if also changed)

                        // Update Pros Image Level
                        EUR_CRM_CommonRoutine.dmlWithPartialSuccess('update', updatePRSUserAnswersBBPNoDuplication);

                        EUR_CRM_MassUpdatePRSFinalResultBatch prsFinalResultBatch = new EUR_CRM_MassUpdatePRSFinalResultBatch(countryCode, 'BrandBuilding');
                        prsFinalResultBatch.processFinalResultCriteria(prSegList);
                    }catch(DmlException e){
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, '' + e));
                    }
                }
            } else if(potential == 'BusinessPotential'){
                system.debug('***updatePRSUserAnswersBP.size(): ' + updatePRSUserAnswers.size());
                if(updatePRSUserAnswers.size() > 0){
                    
                    // Remove duplicates from list of volume potential
                    Set<EUR_CRM_PRS_Answer__c> tempBPUserAnswerSet = new Set<EUR_CRM_PRS_Answer__c>();
                    tempBPUserAnswerSet.addAll(updatePRSUserAnswers);
                    List<EUR_CRM_PRS_Answer__c> updatePRSUserAnswersBPNoDuplication = new List<EUR_CRM_PRS_Answer__c>();
                    updatePRSUserAnswersBPNoDuplication.addAll(tempBPUserAnswerSet);
                    
                    System.debug(updatePRSUserAnswersBPNoDuplication);
                    
                    try{
                        // Update PR Segmentation and Volume Potential Threshold (if also changed)

                        // Update Pros Volume Potential
                        EUR_CRM_CommonRoutine.dmlWithPartialSuccess('update', updatePRSUserAnswersBPNoDuplication);

                        EUR_CRM_MassUpdatePRSFinalResultBatch prsFinalResultBatch = new EUR_CRM_MassUpdatePRSFinalResultBatch(countryCode, 'BusinessPotential');
                        prsFinalResultBatch.processFinalResultCriteria(prSegList);
                    }catch(DmlException e){
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, '' + e));
                    }
                }
            } else if(potential == 'ImageLevel'){
                system.debug('***updatePRSUserAnswersIL.size(): ' + updatePRSUserAnswers.size());
                if(updatePRSUserAnswers.size() > 0){
                    
                    // Remove duplicates from list of volume potential
                    Set<EUR_CRM_PRS_Answer__c> tempILUserAnswerSet = new Set<EUR_CRM_PRS_Answer__c>();
                    tempILUserAnswerSet.addAll(updatePRSUserAnswers);
                    List<EUR_CRM_PRS_Answer__c> updatePRSUserAnswersILNoDuplication = new List<EUR_CRM_PRS_Answer__c>();
                    updatePRSUserAnswersILNoDuplication.addAll(tempILUserAnswerSet);
                    
                    System.debug(updatePRSUserAnswersILNoDuplication);
                    
                    try{
                        // Update PR Segmentation and Volume Potential Threshold (if also changed)

                        // Update Pros Volume Potential
                        EUR_CRM_CommonRoutine.dmlWithPartialSuccess('update', updatePRSUserAnswersILNoDuplication);

                        EUR_CRM_MassUpdatePRSFinalResultBatch prsFinalResultBatch = new EUR_CRM_MassUpdatePRSFinalResultBatch(countryCode, 'ImageLevel');
                        prsFinalResultBatch.processFinalResultCriteria(prSegList);
                    }catch(DmlException e){
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, '' + e));
                    }
                }
            }else if(potential == 'VolumePotential'){
                system.debug('***updatePRSUserAnswersVP.size(): ' + updatePRSUserAnswers.size());
                if(updatePRSUserAnswers.size() > 0){
                    
                    // Remove duplicates from list of volume potential
                    Set<EUR_CRM_PRS_Answer__c> tempVPUserAnswerSet = new Set<EUR_CRM_PRS_Answer__c>();
                    tempVPUserAnswerSet.addAll(updatePRSUserAnswers);
                    List<EUR_CRM_PRS_Answer__c> updatePRSUserAnswersVPNoDuplication = new List<EUR_CRM_PRS_Answer__c>();
                    updatePRSUserAnswersVPNoDuplication.addAll(tempVPUserAnswerSet);
                    
                    System.debug(updatePRSUserAnswersVPNoDuplication);
                    
                    //try{
                        // Update PR Segmentation and Volume Potential Threshold (if also changed)

                        // Update Pros Volume Potential
                        EUR_CRM_CommonRoutine.dmlWithPartialSuccess('update', updatePRSUserAnswersVPNoDuplication);

                        EUR_CRM_MassUpdatePRSFinalResultBatch prsFinalResultBatch = new EUR_CRM_MassUpdatePRSFinalResultBatch(countryCode, 'VolumePotential');
                        prsFinalResultBatch.processFinalResultCriteria(prSegList);
                    //}catch(DmlException e){
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, '' + e));
                    //}
                }
            }
        }
    }
    
    /* Begin Re-calculation methods*/

    /*****************************************************************************************
    *   
    *   Calculate Image Boolean scores
    * 
    *****************************************************************************************/
    public void calculateBoolean(){
    	String developername = 'EUR_' + countryCode + '_PRS_Question_Boolean_Input';
        Set<Id> prsQuestionIds = new Set<Id>();
        List<EUR_CRM_PRS_Question__c> prsQuestions = new List<EUR_CRM_PRS_Question__c>();
        List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswers = new List<EUR_CRM_PRS_Question_Criteria__c>();
        Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>> possibleAnswersMapBool = new Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>>();
        Map<Id, EUR_CRM_PRS_Question__c>  prsQuestionsMap = new Map<Id,EUR_CRM_PRS_Question__c>();
        
        // Retrieve all Criteria Sets (EU) that contain Boolean Criteria Thresholds
        prsQuestions = [SELECT Id, EUR_CRM_PRS_Question_Set__c, RecordType.DeveloperName, EUR_CRM_Question_Weight__c 
                        FROM EUR_CRM_PRS_Question__c
                        WHERE EUR_CRM_PRS_Question_Set__c =: prsQuestionsGOTypeMappingIds 
                        AND Recordtype.DeveloperName =: developername];

        system.debug('prsQuestionsDevName' + prsQuestions.size()); 
        
        // Populate the Id set and Map
        for (EUR_CRM_PRS_Question__c crThrs : prsQuestions){
            prsQuestionIds.add(crThrs.Id);
            prsQuestionsMap.put(crThrs.Id, crThrs);
        }
        
        // List to update
        newBrandBuildingPotential  = new List<EUR_CRM_PRS_Answer__c>();
        
        if(prsQuestionIds.size()>0){
            newBrandBuildingPotential = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_PRS_Segmentation__c, EUR_CRM_PRS_Question__c, EUR_CRM_Weight__c,
                            EUR_CRM_PRS_Question__r.EUR_CRM_Question_Weight__c, EUR_CRM_PRS_Question__r.Recordtype.DeveloperName
                            FROM EUR_CRM_PRS_Answer__c
                            WHERE EUR_CRM_PRS_Segmentation__c IN :prSegIdMap.keyset()
                            AND EUR_CRM_PRS_Question__c IN :prsQuestionIds
                            ORDER BY EUR_CRM_Weight__c];
        }

        // Get all the answers for the retrieved questions
        List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswersTempBool = [SELECT Id, EUR_CRM_Criteria_Weight__c, RecordtypeId,
        														                    EUR_CRM_PRS_Question__c, EUR_CRM_Criteria_Picklist_Value__c, EUR_CRM_Answer_Condition__c, EUR_CRM_Criteria_Threshold_Number__c
                                                                             FROM EUR_CRM_PRS_Question_Criteria__c
                                                                             WHERE EUR_CRM_PRS_Question__c IN :prsQuestionIds
                                                                             ORDER BY EUR_CRM_Criteria_Threshold_Number__c desc];

        // Create a map between each question and its answers                                
        for (EUR_CRM_PRS_Question_Criteria__c ans: prsPossibleAnswersTempBool){
            Id key = ans.EUR_CRM_PRS_Question__c;
            List<EUR_CRM_PRS_Question_Criteria__c> ansList = (possibleAnswersMapBool.containsKey(key)) ? possibleAnswersMapBool.get(key) : new List<EUR_CRM_PRS_Question_Criteria__c>();
            ansList.add(ans);
            possibleAnswersMapBool.put(key,ansList);
        }
        
        Double answerWeight = 0;       
        system.debug('prsQuestionsMap' + prsQuestionsMap);

        // Recalculate the PROS's answer weight
        for (EUR_CRM_PRS_Answer__c userAnswer : newBrandBuildingPotential){          
            // Get the weight of each question
            for (EUR_CRM_PRS_Question_Criteria__c ca : possibleAnswersMapBool.get(userAnswer.EUR_CRM_PRS_Question__c) ){
                // If the value of the answer is null set it to false
                ca.EUR_CRM_Criteria_Picklist_Value__c = (ca.EUR_CRM_Criteria_Picklist_Value__c!=null) ? ca.EUR_CRM_Criteria_Picklist_Value__c : '';
                // Check if the answer is correct
                if (ca.EUR_CRM_Criteria_Picklist_Value__c.equalsIgnorecase(userAnswer.EUR_CRM_Answer__c)){
                    answerWeight = ca.EUR_CRM_Criteria_Weight__c * prsQuestionsMap.get(userAnswer.EUR_CRM_PRS_Question__c).EUR_CRM_Question_Weight__c;
                } 
            }
            userAnswer.EUR_CRM_Weight__c = answerWeight/100;
            updatePRSUserAnswers.add(userAnswer);
        }
    }
    
    public void calculateInteger(){

    	String developername = 'EUR_' + countryCode + '_PRS_Question_Number_Input';
        Double answerWeight = 0;
        Set<Id> prsQuestionIds = new Set<Id>();
        List<EUR_CRM_PRS_Answer__c> updatePRSUserAnswersInt = null;
        List<EUR_CRM_PRS_Question__c> prsQuestions = new List<EUR_CRM_PRS_Question__c>();
        Map <Id,EUR_CRM_PRS_Question__c >  prsQuestionsMap = new Map<Id,EUR_CRM_PRS_Question__c>();
        
        updatePRSUserAnswersInt = new List<EUR_CRM_PRS_Answer__c>();
        
        Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>> possibleAnswersMap = new Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>>();
        
        // Get Criteria thresholds which answers are in integer fromat
        prsQuestions = [SELECT Id, EUR_CRM_PRS_Question_Set__c, RecordType.DeveloperName, EUR_CRM_Question_Weight__c 
                    FROM EUR_CRM_PRS_Question__c
                    WHERE EUR_CRM_PRS_Question_Set__c =: prsQuestionsGOTypeMappingIds
                    AND Recordtype.DeveloperName = :developername];

        system.debug('***prsQuestionsDevNameInt: ' + prsQuestions.size()); 
        
        for (EUR_CRM_PRS_Question__c e: prsQuestions){
            prsQuestionIds.add(e.Id);
            prsQuestionsMap.put(e.Id, e);
        }
        
        if(prsQuestionIds.size()>0){
            // Get all Image levels to be updated
            updatePRSUserAnswersInt = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_PRS_Segmentation__c, EUR_CRM_PRS_Question__c, EUR_CRM_PRS_Question__r.EUR_CRM_Question_Weight__c,
                                            EUR_CRM_PRS_Question__r.Recordtype.DeveloperName, EUR_CRM_Weight__c
                                            FROM EUR_CRM_PRS_Answer__c
                                            WHERE EUR_CRM_PRS_Segmentation__c IN :prSegIdMap.keyset()
                                            AND EUR_CRM_PRS_Question__c IN :prsQuestionIds 
                                            ORDER BY EUR_CRM_Weight__c];
        }
        // List of the answers for the retrieved questions
        List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswersTemp = [SELECT Id, EUR_CRM_Criteria_Weight__c, RecordtypeId, EUR_CRM_PRS_Question__c, 
                                                                                EUR_CRM_Criteria_Picklist_Value__c, EUR_CRM_Answer_Condition__c, EUR_CRM_Criteria_Threshold_Number__c 
                                                                         FROM EUR_CRM_PRS_Question_Criteria__c
                                                                         WHERE EUR_CRM_PRS_Question__c IN :prsQuestionIds
                                                                         ORDER BY EUR_CRM_Criteria_Weight__c desc, EUR_CRM_Criteria_Threshold_Number__c desc]; 
                 
        // Map criteria thresholds to answers                                                    
        for (EUR_CRM_PRS_Question_Criteria__c ans : prsPossibleAnswersTemp){
            Id key = ans.EUR_CRM_PRS_Question__c;
            List<EUR_CRM_PRS_Question_Criteria__c> ansList = (possibleAnswersMap.containsKey(key)) ? possibleAnswersMap.get(key) : new List<EUR_CRM_PRS_Question_Criteria__c>();
            ansList.add(ans);
            possibleAnswersMap.put(key,ansList);
        }

        for (EUR_CRM_PRS_Answer__c userAnswer : updatePRSUserAnswersInt){
            Double answer;
            try{
                String a = userAnswer.EUR_CRM_Answer__c;
                a = a.replace('.','');
                a = a.trim();
                answer = Double.valueOf(a);
            }catch(Exception e){
                continue;
            } finally {
                // Set null answer to 0
                if(answer == null) {
                    answer = 0;
                }
            }
            
            answerWeight = calculateAnswerWeight(
                possibleAnswersMap.get(userAnswer.EUR_CRM_PRS_Question__c),
                answer,
                prsQuestionsMap.get(userAnswer.EUR_CRM_PRS_Question__c),
                prsQuestionsMap.get(userAnswer.EUR_CRM_PRS_Question__c).RecordType.DeveloperName
            );
            
            userAnswer.EUR_CRM_Weight__c = answerWeight/100;
            updatePRSUserAnswers.add(userAnswer);
        }
    }
    
    public void calculatePicklist(){
    	String developername = 'EUR_' + countryCode + '_PRS_Question_Picklist_Input';
        Set<Id> prsQuestionIds = new Set<Id>();
        List<EUR_CRM_PRS_Question__c> prsQuestions = new List<EUR_CRM_PRS_Question__c>();
        List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswers = new List<EUR_CRM_PRS_Question_Criteria__c>();
        Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>> possibleAnswersMapPick = new Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>>();
        List<EUR_CRM_PRS_Answer__c> updatePRSUserAnswersPick = null;
        
        system.debug('prsQuestionsDevNameInt' + prsQuestions.size()); 
        Double answerWeight = 0;
        
        Map <Id,EUR_CRM_PRS_Question__c >  prsQuestionsWeightMap = new Map<Id,EUR_CRM_PRS_Question__c>();
        for (EUR_CRM_PRS_Question__c e: [SELECT Id, EUR_CRM_PRS_Question_Set__c, RecordType.DeveloperName, EUR_CRM_Question_Weight__c FROM EUR_CRM_PRS_Question__c
                                                    WHERE EUR_CRM_PRS_Question_Set__c =: prsQuestionsGOTypeMappingIds  AND Recordtype.DeveloperName =: developername]){
            prsQuestionIds.add(e.Id);
            prsQuestionsWeightMap.put(e.Id, e);
            
        }
        system.debug('prSegIdMap' + prSegIdMap);
        system.debug('prSegIdMap2' + prSegIdMap.keyset());
        
        updatePRSUserAnswersPick = new List<EUR_CRM_PRS_Answer__c>();
        
        if(prsQuestionIds.size()>0){
        updatePRSUserAnswersPick = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_PRS_Segmentation__c, EUR_CRM_PRS_Question__c, 
                                            EUR_CRM_PRS_Question__r.EUR_CRM_Question_Weight__c,EUR_CRM_PRS_Question__r.Recordtype.DeveloperName 
                                            FROM EUR_CRM_PRS_Answer__c
                                            WHERE EUR_CRM_PRS_Segmentation__c IN :prSegIdMap.keyset()
                                            AND EUR_CRM_PRS_Question__c IN :prsQuestionIds ORDER BY EUR_CRM_Weight__c];
          }                          
        List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswersTempPick = [SELECT Id, EUR_CRM_Criteria_Weight__c, RecordtypeId, EUR_CRM_PRS_Question__c, 
                                                                                    EUR_CRM_Criteria_Picklist_Value__c,EUR_CRM_Answer_Condition__c, EUR_CRM_Criteria_Threshold_Number__c 
                                                                             FROM EUR_CRM_PRS_Question_Criteria__c
                                                                             WHERE EUR_CRM_PRS_Question__c IN :prsQuestionIds
                                                                             ORDER BY EUR_CRM_Criteria_Threshold_Number__c desc ];     
        
        for (EUR_CRM_PRS_Question_Criteria__c ans: prsPossibleAnswersTempPick){
            Id key = ans.EUR_CRM_PRS_Question__c;
            List<EUR_CRM_PRS_Question_Criteria__c> ansList = (possibleAnswersMapPick.containsKey(key))?possibleAnswersMapPick.get(key):new List<EUR_CRM_PRS_Question_Criteria__c>();
            ansList.add(ans);
            possibleAnswersMapPick.put(key,ansList);
        }
                        
        for (EUR_CRM_PRS_Answer__c p : updatePRSUserAnswersPick){
            EUR_CRM_PRS_Answer__c userAnswer = new EUR_CRM_PRS_Answer__c();
            userAnswer.EUR_CRM_PRS_Question__c = p.EUR_CRM_PRS_Question__c;
            userAnswer.EUR_CRM_PRS_Segmentation__c = p.EUR_CRM_PRS_Segmentation__c;
            userAnswer.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
            userAnswer.id = p.id;
        
            for (EUR_CRM_PRS_Question_Criteria__c ca : possibleAnswersMapPick.get(p.EUR_CRM_PRS_Question__c)){                      
                if (prsQuestionsWeightMap.get(p.EUR_CRM_PRS_Question__c).RecordType.DeveloperName.contains(developername)){
                    ca.EUR_CRM_Criteria_Picklist_Value__c = (ca.EUR_CRM_Criteria_Picklist_Value__c!=null)?ca.EUR_CRM_Criteria_Picklist_Value__c:'';
                    if (ca.EUR_CRM_Criteria_Picklist_Value__c.equalsIgnorecase(p.EUR_CRM_Answer__c)){
                        answerWeight = ca.EUR_CRM_Criteria_Weight__c * prsQuestionsWeightMap.get(p.EUR_CRM_PRS_Question__c).EUR_CRM_Question_Weight__c;
                    }   
                }
            }
            userAnswer.EUR_CRM_Weight__c = answerWeight/100;
            updatePRSUserAnswers.add(userAnswer);
        }
    }
    
    public void calculateCurrency(){
    	String developername = 'EUR_' + countryCode + '_PRS_Question_Currency_Input';
        Set<Id> prsQuestionIds = new Set<Id>();
        List<EUR_CRM_PRS_Question__c> prsQuestions = new List<EUR_CRM_PRS_Question__c>();
        List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswers = new List<EUR_CRM_PRS_Question_Criteria__c>();
        Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>> possibleAnswersMapCurr = new Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>>();
        List<EUR_CRM_PRS_Answer__c> updatePRSUserAnswersCurr = null;
        
        prsQuestions = [SELECT Id, EUR_CRM_PRS_Question_Set__c, RecordType.DeveloperName, EUR_CRM_Question_Weight__c 
                    FROM EUR_CRM_PRS_Question__c
                    WHERE EUR_CRM_PRS_Question_Set__c =: prsQuestionsGOTypeMappingIds  AND Recordtype.DeveloperName =: developername];
                    
        system.debug('prsQuestionsDevNameCurr' + prsQuestions.size()); 
        Double answerWeight = 0;
        Map <Id,EUR_CRM_PRS_Question__c >  prsQuestionsWeightMap = new Map<Id,EUR_CRM_PRS_Question__c>();
        
        for (EUR_CRM_PRS_Question__c e: prsQuestions){
            system.debug('@@@calculateCurrency' + e.RecordType.DeveloperName);
            prsQuestionIds.add(e.Id);
            prsQuestionsWeightMap.put(e.Id, e);
    
        }
        
        updatePRSUserAnswersCurr = new List<EUR_CRM_PRS_Answer__c>();
        
        if(prsQuestionIds.size()>0){
        updatePRSUserAnswersCurr = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_PRS_Segmentation__c, EUR_CRM_PRS_Question__c, 
                                            EUR_CRM_PRS_Question__r.EUR_CRM_Question_Weight__c,EUR_CRM_PRS_Question__r.Recordtype.DeveloperName
                                            FROM EUR_CRM_PRS_Answer__c
                                            WHERE EUR_CRM_PRS_Segmentation__c IN: prSegIdMap.keyset()
                                            AND EUR_CRM_PRS_Question__c IN: prsQuestionIds ORDER BY EUR_CRM_Weight__c];
        }
        List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswersTempCurr = [SELECT Id, EUR_CRM_Criteria_Weight__c, RecordtypeId, EUR_CRM_PRS_Question__c, 
                                                                                    EUR_CRM_Criteria_Picklist_Value__c,EUR_CRM_Answer_Condition__c, EUR_CRM_Criteria_Threshold_Number__c, EUR_CRM_Criteria_Threshold_Currency__c 
                                                                             FROM EUR_CRM_PRS_Question_Criteria__c
                                                                             WHERE EUR_CRM_PRS_Question__c IN: prsQuestionIds
                                                                             ORDER BY EUR_CRM_Criteria_Weight__c desc, EUR_CRM_Criteria_Threshold_Currency__c desc]; 
        
        for (EUR_CRM_PRS_Question_Criteria__c ans: prsPossibleAnswersTempCurr){
            Id key = ans.EUR_CRM_PRS_Question__c;
            List<EUR_CRM_PRS_Question_Criteria__c> ansList = (possibleAnswersMapCurr.containsKey(key))?possibleAnswersMapCurr.get(key):new List<EUR_CRM_PRS_Question_Criteria__c>();
            ansList.add(ans);
            possibleAnswersMapCurr.put(key,ansList);
        }                                           
        
        for (EUR_CRM_PRS_Answer__c p : updatePRSUserAnswersCurr){
            Double answer;
            try{
                answer = Double.valueOf(p.EUR_CRM_Answer__c);
            }catch(Exception e){
                continue;
            } finally {
                // Set null answer to 0
                if(answer == null) {
                    answer = 0;
                }
            }

            answerWeight = calculateAnswerWeight(
                possibleAnswersMapCurr.get(p.EUR_CRM_PRS_Question__c),
                answer,
                prsQuestionsWeightMap.get(p.EUR_CRM_PRS_Question__c),
                prsQuestionsWeightMap.get(p.EUR_CRM_PRS_Question__c).RecordType.DeveloperName
            );
            
            p.EUR_CRM_Weight__c = answerWeight/100;
            updatePRSUserAnswers.add(p);
        }                     
    }
    
    public void calculateText(){
    	String developername = 'EUR_' + countryCode + '_PRS_Question_Text_Input';
        Set<Id> prsQuestionIds = new Set<Id>();
        List<EUR_CRM_PRS_Question__c> prsQuestions = new List<EUR_CRM_PRS_Question__c>();
        List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswers = new List<EUR_CRM_PRS_Question_Criteria__c>();
        Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>> possibleAnswersMapText = new Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>>();
        List<EUR_CRM_PRS_Answer__c> updatePRSUserAnswersText = null;
        
        prsQuestions = [SELECT Id, EUR_CRM_PRS_Question_Set__c, RecordType.DeveloperName, EUR_CRM_Question_Weight__c FROM EUR_CRM_PRS_Question__c
                    WHERE EUR_CRM_PRS_Question_Set__c =: prsQuestionsGOTypeMappingIds  AND Recordtype.DeveloperName =: developername];
        system.debug('prsQuestionsDevNameText' + prsQuestions.size()); 
        Double answerWeight = 0;
        Map <Id,EUR_CRM_PRS_Question__c >  prsQuestionsWeightMap = new Map<Id,EUR_CRM_PRS_Question__c>();
        
        for (EUR_CRM_PRS_Question__c e: prsQuestions){
            system.debug('@@@calculateText' + e.RecordType.DeveloperName);
            prsQuestionIds.add(e.Id);
            prsQuestionsWeightMap.put(e.Id, e);
        }

        system.debug('prSegIdMap' + prSegIdMap);
        system.debug('prSegIdMap2' + prSegIdMap.keyset());
        
        updatePRSUserAnswersText = new List<EUR_CRM_PRS_Answer__c>();
        
        if(prsQuestionIds.size()>0){
        updatePRSUserAnswersText = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_PRS_Segmentation__c, EUR_CRM_PRS_Question__c, EUR_CRM_PRS_Question__r.EUR_CRM_Question_Weight__c,
                                            EUR_CRM_PRS_Question__r.Recordtype.DeveloperName
                                            FROM EUR_CRM_PRS_Answer__c
                                            WHERE EUR_CRM_PRS_Segmentation__c IN: prSegIdMap.keyset()
                                            AND EUR_CRM_PRS_Question__c IN: prsQuestionIds ORDER BY EUR_CRM_Weight__c];    
        }
                                       
        for (EUR_CRM_PRS_Answer__c p : updatePRSUserAnswersText){
            EUR_CRM_PRS_Answer__c userAnswer = new EUR_CRM_PRS_Answer__c();
            userAnswer.EUR_CRM_PRS_Question__c = p.EUR_CRM_PRS_Question__c;
            userAnswer.EUR_CRM_PRS_Segmentation__c = p.EUR_CRM_PRS_Segmentation__c;
            userAnswer.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
            userAnswer.id = p.id;

            if (prsQuestionsWeightMap.get(p.EUR_CRM_PRS_Question__c).RecordType.DeveloperName.contains('EUR_CRM_PRS_Question_Text_Input')){               
                userAnswer.EUR_CRM_Weight__c = 0;      
            }
            updatePRSUserAnswers.add(userAnswer);
        }
    }
    
    /********************
    Calculate Volume Potential
    ********************/
    /*public void calculateBooleanVol(){
        Set<Id> prsQuestionIds = new Set<Id>();
        List<EUR_CRM_PRS_Question__c> prsQuestions = new List<EUR_CRM_PRS_Question__c>();
        List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswers = new List<EUR_CRM_PRS_Question_Criteria__c>();
        List<EUR_CRM_PRS_Answer__c> updateProsVolPotentialListBoolean = null;
        List<EUR_CRM_PRS_Answer__c> updateProsVolPotentialListBoolean2 = null;
        Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>> possibleAnswersMapBooleanVol = new Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>>();

        Map<Id,EUR_CRM_PRS_Question__c>  volThresholdWeightMap = new Map<Id,EUR_CRM_PRS_Question__c>();

        for (EUR_CRM_PRS_Question__c e: [SELECT Id, EUR_CRM_PRS_Question_Set__c, RecordType.DeveloperName, EUR_CRM_Question_Weight__c 
                                         FROM EUR_CRM_PRS_Question__c
                                         WHERE EUR_CRM_PRS_Question_Set__c =: prsQuestionsGOTypeMappingIds  
                                         AND Recordtype.DeveloperName = 'EUR_CRM_PRS_Question_Boolean_Input'])
        {
            //system.debug('eeeeee' + e.RecordType.DeveloperName);
            prsQuestionIds.add(e.Id);
            volThresholdWeightMap.put(e.Id, e);
        }
        system.debug('prSegIdMap' + prSegIdMap);
        system.debug('prSegIdMap2' + prSegIdMap.keyset());
        
        updateProsVolPotentialListBoolean = new List<EUR_CRM_PRS_Answer__c>();
        
        if(prsQuestionIds.size()>0){
        updateProsVolPotentialListBoolean = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_PRS_Segmentation__c, EUR_CRM_PRS_Question__c, 
                                                    EUR_CRM_PRS_Question__r.EUR_CRM_Question_Weight__c,EUR_CRM_PRS_Question__r.Recordtype.DeveloperName   
                                             FROM EUR_CRM_PRS_Answer__c
                                             WHERE EUR_CRM_PRS_Segmentation__c IN: prSegIdMap.keyset()
                                             AND EUR_CRM_PRS_Question__c IN: prsQuestionIds
                                             ORDER BY EUR_CRM_Weight__c];
        }
        List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswersTempBool = [SELECT Id, EUR_CRM_Criteria_Weight__c, RecordtypeId, EUR_CRM_PRS_Question__c, 
                                                                                    EUR_CRM_Criteria_Picklist_Value__c,EUR_CRM_Answer_Condition__c, EUR_CRM_Criteria_Threshold_Number__c 
                                                                             FROM EUR_CRM_PRS_Question_Criteria__c
                                                                             WHERE EUR_CRM_PRS_Question__c IN: prsQuestionIds
                                                                             ORDER BY EUR_CRM_Criteria_Threshold_Number__c desc]; 
                
        for (EUR_CRM_PRS_Question_Criteria__c ans: prsPossibleAnswersTempBool){
            Id key = ans.EUR_CRM_PRS_Question__c;
            List<EUR_CRM_PRS_Question_Criteria__c> ansList = (possibleAnswersMapBooleanVol.containsKey(key))?possibleAnswersMapBooleanVol.get(key):new List<EUR_CRM_PRS_Question_Criteria__c>();
            ansList.add(ans);
            possibleAnswersMapBooleanVol.put(key,ansList);
        }
        
        Double answerWeight = 0;
        for (EUR_CRM_PRS_Answer__c p : updateProsVolPotentialListBoolean){   
            EUR_CRM_PRS_Answer__c pv = new EUR_CRM_PRS_Answer__c();
            pv.EUR_CRM_PRS_Question__c = p.EUR_CRM_PRS_Question__c;
            pv.EUR_CRM_PRS_Segmentation__c = p.EUR_CRM_PRS_Segmentation__c;
            pv.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
            pv.id = p.id;
            
            for (EUR_CRM_PRS_Question_Criteria__c ca : possibleAnswersMapBooleanVol.get(p.EUR_CRM_PRS_Question__c)){    
                ca.EUR_CRM_Criteria_Picklist_Value__c = (ca.EUR_CRM_Criteria_Picklist_Value__c!=null)?ca.EUR_CRM_Criteria_Picklist_Value__c:'';
                if (volThresholdWeightMap.get(p.EUR_CRM_PRS_Question__c).RecordType.DeveloperName.contains('EUR_CRM_PRS_Question_Boolean_Input')){
                    if (ca.EUR_CRM_Criteria_Picklist_Value__c.equalsIgnorecase(p.EUR_CRM_Answer__c)){
                        answerWeight = ca.EUR_CRM_Criteria_Weight__c * volThresholdWeightMap.get(p.EUR_CRM_PRS_Question__c).EUR_CRM_Question_Weight__c;
                    }   
                }                       
            }
            //system.debug('#####answerWeight' + answerWeight/100);
            pv.EUR_CRM_Weight__c = answerWeight/100;
            updatePRSUserAnswersBP.add(pv);
        }
    }
    
    public void calculateIntegerVol(){
        Set<Id> prsQuestionIds = new Set<Id>();
        List<EUR_CRM_PRS_Question__c> prsQuestions = new List<EUR_CRM_PRS_Question__c>();
        List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswers = new List<EUR_CRM_PRS_Question_Criteria__c>();
        List<EUR_CRM_PRS_Answer__c> updateProsVolPotentialListInt = null;
        Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>> possibleAnswersMapIntVol = new Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>>();

        Double answerWeight = 0;
        Map <Id,EUR_CRM_PRS_Question__c >  volThresholdWeightMapInt = new Map<Id,EUR_CRM_PRS_Question__c>();
        
        for (EUR_CRM_PRS_Question__c e: [SELECT Id, EUR_CRM_PRS_Question_Set__c, RecordType.DeveloperName, EUR_CRM_Question_Weight__c FROM EUR_CRM_PRS_Question__c
                                                    WHERE EUR_CRM_PRS_Question_Set__c =: prsQuestionsGOTypeMappingIds  AND Recordtype.DeveloperName =:'EUR_CRM_PRS_Question_Integer_Input']){
            prsQuestionIds.add(e.Id);
            volThresholdWeightMapInt.put(e.Id, e);
        }
        system.debug('prSegIdMap' + prSegIdMap);
        system.debug('prSegIdMap2' + prSegIdMap.keyset());
        
        updateProsVolPotentialListInt = new List<EUR_CRM_PRS_Answer__c>();
        
        if(prsQuestionIds.size()>0){
        updateProsVolPotentialListInt = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_PRS_Segmentation__c, EUR_CRM_PRS_Question__c, 
                                                EUR_CRM_PRS_Question__r.EUR_CRM_Question_Weight__c,EUR_CRM_PRS_Question__r.Recordtype.DeveloperName
                                         FROM EUR_CRM_PRS_Answer__c
                                         WHERE EUR_CRM_PRS_Segmentation__c IN: prSegIdMap.keyset()
                                         AND EUR_CRM_PRS_Question__c IN: prsQuestionIds // AND EUR_CRM_Is_Mass_Update__c = true 
                                         ORDER BY EUR_CRM_Weight__c];
        }
        system.debug('updateProsVolPotentialListInt' + updateProsVolPotentialListInt.size());   
        
        List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswersTempInt = [SELECT Id, EUR_CRM_Criteria_Weight__c, RecordtypeId, EUR_CRM_PRS_Question__c, 
                                                                                   EUR_CRM_Criteria_Picklist_Value__c,EUR_CRM_Answer_Condition__c, EUR_CRM_Criteria_Threshold_Number__c 
                                                                            FROM EUR_CRM_PRS_Question_Criteria__c
                                                                            WHERE EUR_CRM_PRS_Question__c IN: prsQuestionIds
                                                                            ORDER BY EUR_CRM_Criteria_Weight__c desc, EUR_CRM_Criteria_Threshold_Number__c desc ]; 
        
        for (EUR_CRM_PRS_Question_Criteria__c ans: prsPossibleAnswersTempInt){
            Id key = ans.EUR_CRM_PRS_Question__c;
            List<EUR_CRM_PRS_Question_Criteria__c> ansList = (possibleAnswersMapIntVol.containsKey(key))?possibleAnswersMapIntVol.get(key):new List<EUR_CRM_PRS_Question_Criteria__c>();
            ansList.add(ans);
            possibleAnswersMapIntVol.put(key,ansList);
        }                   
        
        for (EUR_CRM_PRS_Answer__c p : updateProsVolPotentialListInt){
	        Double answer;
	        try{
	            String a = p.EUR_CRM_Answer__c;
	            a = a.replace('.','');
	            a = a.trim();
	            answer = Double.valueOf(a);
	        }catch(Exception e){
	            continue;
	        } finally {
	            // Set null answer to 0
	            if(answer == null) {
	                answer = 0;
	            }
	        }
	        
            answerWeight = calculateAnswerWeight(
                possibleAnswersMapIntVol.get(p.EUR_CRM_PRS_Question__c),
                answer,
                volThresholdWeightMapInt.get(p.EUR_CRM_PRS_Question__c),
                volThresholdWeightMapInt.get(p.EUR_CRM_PRS_Question__c).RecordType.DeveloperName
            );	        
              
            p.EUR_CRM_Weight__c = answerWeight/100;
            system.debug('#####answerWeight2' + p);
            updatePRSUserAnswersBP.add(p);
        }                       
    }
    
    public void calculatePicklistVol(){
        Set<Id> prsQuestionIds = new Set<Id>();
        List<EUR_CRM_PRS_Question__c> prsQuestions = new List<EUR_CRM_PRS_Question__c>();
        List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswers = new List<EUR_CRM_PRS_Question_Criteria__c>();
        List<EUR_CRM_PRS_Answer__c> updateProsVolPotentialListPick = null;
        Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>> possibleAnswersMapIntVol = new Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>>();

        Double answerWeight = 0;
        Map <Id,EUR_CRM_PRS_Question__c >  volThresholdWeightMapPick = new Map<Id,EUR_CRM_PRS_Question__c>();
        
        for (EUR_CRM_PRS_Question__c e: [SELECT Id, EUR_CRM_PRS_Question_Set__c, RecordType.DeveloperName, EUR_CRM_Question_Weight__c 
                                                    FROM EUR_CRM_PRS_Question__c
                                                    WHERE EUR_CRM_PRS_Question_Set__c =: prsQuestionsGOTypeMappingIds  AND Recordtype.DeveloperName =:'EUR_CRM_PRS_Question_Picklist_Input']){
            prsQuestionIds.add(e.Id);
            volThresholdWeightMapPick.put(e.Id, e);
        }
        
        system.debug('prSegIdMap' + prSegIdMap);
        system.debug('prSegIdMap2' + prSegIdMap.keyset());
        updateProsVolPotentialListPick = new List<EUR_CRM_PRS_Answer__c>();
        
        updateProsVolPotentialListPick = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_PRS_Segmentation__c, EUR_CRM_PRS_Question__c, 
                                            EUR_CRM_PRS_Question__r.EUR_CRM_Question_Weight__c,EUR_CRM_PRS_Question__r.Recordtype.DeveloperName 
                                            FROM EUR_CRM_PRS_Answer__c
                                            WHERE EUR_CRM_PRS_Segmentation__c IN: prSegIdMap.keyset()
                                            AND EUR_CRM_PRS_Question__c IN: prsQuestionIds
                                            ORDER BY EUR_CRM_Weight__c];
        
        List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswersTempPick = [SELECT Id, EUR_CRM_Criteria_Weight__c, RecordtypeId, EUR_CRM_PRS_Question__c, 
                                                                                    EUR_CRM_Criteria_Picklist_Value__c,EUR_CRM_Answer_Condition__c, EUR_CRM_Criteria_Threshold_Number__c 
                                                                             FROM EUR_CRM_PRS_Question_Criteria__c
                                                                             WHERE EUR_CRM_PRS_Question__c IN: prsQuestionIds
                                                                             ORDER BY EUR_CRM_Criteria_Threshold_Number__c desc];     
        
        for (EUR_CRM_PRS_Question_Criteria__c ans: prsPossibleAnswersTempPick){
            Id key = ans.EUR_CRM_PRS_Question__c;
            List<EUR_CRM_PRS_Question_Criteria__c> ansList = (possibleAnswersMapIntVol.containsKey(key))?possibleAnswersMapIntVol.get(key):new List<EUR_CRM_PRS_Question_Criteria__c>();
            ansList.add(ans);
            possibleAnswersMapIntVol.put(key,ansList);
        }               

        for (EUR_CRM_PRS_Answer__c p : updateProsVolPotentialListPick){
            EUR_CRM_PRS_Answer__c pv = new EUR_CRM_PRS_Answer__c();
            pv.EUR_CRM_PRS_Question__c = p.EUR_CRM_PRS_Question__c;
            pv.EUR_CRM_PRS_Segmentation__c = p.EUR_CRM_PRS_Segmentation__c;
            pv.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
            pv.id = p.id;
            
            for (EUR_CRM_PRS_Question_Criteria__c ca : possibleAnswersMapIntVol.get(p.EUR_CRM_PRS_Question__c)){                
                if (volThresholdWeightMapPick.get(p.EUR_CRM_PRS_Question__c).RecordType.DeveloperName.contains('EUR_CRM_PRS_Question_Picklist_Input')){
                    ca.EUR_CRM_Criteria_Picklist_Value__c = (ca.EUR_CRM_Criteria_Picklist_Value__c!=null)?ca.EUR_CRM_Criteria_Picklist_Value__c:'';
                    if (ca.EUR_CRM_Criteria_Picklist_Value__c.equalsIgnorecase(p.EUR_CRM_Answer__c)){
                        answerWeight = ca.EUR_CRM_Criteria_Weight__c * volThresholdWeightMapPick.get(p.EUR_CRM_PRS_Question__c).EUR_CRM_Question_Weight__c;
                    }                           
                }
            }
            pv.EUR_CRM_Weight__c = answerWeight/100;
            updatePRSUserAnswersBP.add(pv);
        }      
    }
    
    public void calculateCurrencyVol(){
        Set<Id> prsQuestionIds = new Set<Id>();
        List<EUR_CRM_PRS_Question__c> prsQuestions = new List<EUR_CRM_PRS_Question__c>();
        List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswers = new List<EUR_CRM_PRS_Question_Criteria__c>();
        List<EUR_CRM_PRS_Answer__c> updateProsVolPotentialListCurr = null;
        Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>> possibleAnswersMapVolCurr = new Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>>();
 
        Double answerWeight = 0;
        Map <Id,EUR_CRM_PRS_Question__c >  volThresholdWeightMapCurr = new Map<Id,EUR_CRM_PRS_Question__c>();
        
        for (EUR_CRM_PRS_Question__c e: [SELECT Id, EUR_CRM_PRS_Question_Set__c, RecordType.DeveloperName, EUR_CRM_Question_Weight__c 
                                                    FROM EUR_CRM_PRS_Question__c
                                                    WHERE EUR_CRM_PRS_Question_Set__c =: prsQuestionsGOTypeMappingIds  AND Recordtype.DeveloperName =:'EUR_CRM_PRS_Question_Currency_Input']){
            prsQuestionIds.add(e.Id);
            volThresholdWeightMapCurr.put(e.Id, e);
        }
        system.debug('prSegIdMap' + prSegIdMap);
        system.debug('prSegIdMap2' + prSegIdMap.keyset());
        
        updateProsVolPotentialListCurr = new List<EUR_CRM_PRS_Answer__c>();
        updateProsVolPotentialListCurr = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_PRS_Segmentation__c, EUR_CRM_PRS_Question__c, EUR_CRM_PRS_Question__r.EUR_CRM_Question_Weight__c,
                                            EUR_CRM_PRS_Question__r.Recordtype.DeveloperName FROM EUR_CRM_PRS_Answer__c
                                            WHERE EUR_CRM_PRS_Segmentation__c IN: prSegIdMap.keyset()
                                            AND EUR_CRM_PRS_Question__c IN: prsQuestionIds
                                            ORDER BY EUR_CRM_Weight__c ];
        
        List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswersTempCurr = [SELECT Id, EUR_CRM_Criteria_Weight__c, RecordtypeId, EUR_CRM_PRS_Question__c, 
                                                                                    EUR_CRM_Criteria_Picklist_Value__c,EUR_CRM_Answer_Condition__c, EUR_CRM_Criteria_Threshold_Number__c, EUR_CRM_Criteria_Threshold_Currency__c 
                                                                             FROM EUR_CRM_PRS_Question_Criteria__c
                                                                             WHERE EUR_CRM_PRS_Question__c IN: prsQuestionIds
                                                                             ORDER BY EUR_CRM_Criteria_Weight__c desc, EUR_CRM_Criteria_Threshold_Currency__c desc]; 
                        
        for (EUR_CRM_PRS_Question_Criteria__c ans: prsPossibleAnswersTempCurr){
            Id key = ans.EUR_CRM_PRS_Question__c;
            List<EUR_CRM_PRS_Question_Criteria__c> ansList = (possibleAnswersMapVolCurr.containsKey(key))?possibleAnswersMapVolCurr.get(key):new List<EUR_CRM_PRS_Question_Criteria__c>();
            ansList.add(ans);
            possibleAnswersMapVolCurr.put(key,ansList);
        }               
                                                    
        for (EUR_CRM_PRS_Answer__c p : updateProsVolPotentialListCurr){
            Double answer;
            try{
                answer = Double.valueOf(p.EUR_CRM_Answer__c);
            }catch(Exception e){
                continue;
            } finally {
                if(answer == null) {
                    answer = 0;
                }
            }
            
            answerWeight = calculateAnswerWeight(
                possibleAnswersMapVolCurr.get(p.EUR_CRM_PRS_Question__c),
                answer,
                volThresholdWeightMapCurr.get(p.EUR_CRM_PRS_Question__c),
                volThresholdWeightMapCurr.get(p.EUR_CRM_PRS_Question__c).RecordType.DeveloperName
            );            
            
            p.EUR_CRM_Weight__c = answerWeight/100;
            updatePRSUserAnswersBP.add(p);
        }                     
    }
   
    public void calculateTextVol(){
        Set<Id> prsQuestionIds = new Set<Id>();
        List<EUR_CRM_PRS_Question__c> prsQuestions = new List<EUR_CRM_PRS_Question__c>();
        List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswers = new List<EUR_CRM_PRS_Question_Criteria__c>();
        List<EUR_CRM_PRS_Answer__c> updateProsVolPotentialListText = null;
        Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>> possibleAnswersMapVolText = new Map<Id,List<EUR_CRM_PRS_Question_Criteria__c>>();
        
        Double answerWeight = 0;
        Map <Id,EUR_CRM_PRS_Question__c >  volThresholdWeightMapText = new Map<Id,EUR_CRM_PRS_Question__c>();
        
        for (EUR_CRM_PRS_Question__c e: [SELECT Id, EUR_CRM_PRS_Question_Set__c, RecordType.DeveloperName, EUR_CRM_Question_Weight__c 
                                         FROM EUR_CRM_PRS_Question__c
                                         WHERE EUR_CRM_PRS_Question_Set__c =: prsQuestionsGOTypeMappingIds
                                         AND Recordtype.DeveloperName =:'EUR_CRM_PRS_Question_Text_Input']){
            prsQuestionIds.add(e.Id);
            volThresholdWeightMapText.put(e.Id, e);
        }
        
        system.debug('prSegIdMap' + prSegIdMap);
        system.debug('prSegIdMap2' + prSegIdMap.keyset());
        
        updateProsVolPotentialListText = new List<EUR_CRM_PRS_Answer__c>();
        updateProsVolPotentialListText = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_PRS_Segmentation__c, EUR_CRM_PRS_Question__c, EUR_CRM_PRS_Question__r.EUR_CRM_Question_Weight__c,
                                                EUR_CRM_PRS_Question__r.Recordtype.DeveloperName
                                         FROM EUR_CRM_PRS_Answer__c
                                         WHERE EUR_CRM_PRS_Segmentation__c IN: prSegIdMap.keyset()
                                         AND EUR_CRM_PRS_Question__c IN: prsQuestionIds
                                         ORDER BY EUR_CRM_Weight__c];                                        
            
        for (EUR_CRM_PRS_Answer__c p : updateProsVolPotentialListText){
            EUR_CRM_PRS_Answer__c pv = new EUR_CRM_PRS_Answer__c();
            pv.EUR_CRM_PRS_Question__c = p.EUR_CRM_PRS_Question__c;
            pv.EUR_CRM_PRS_Segmentation__c = p.EUR_CRM_PRS_Segmentation__c;
            pv.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
            pv.id = p.id;

            if (volThresholdWeightMapText.get(p.EUR_CRM_PRS_Question__c).RecordType.DeveloperName.contains('EUR_CRM_PRS_Question_Text_Input')){
                pv.EUR_CRM_Weight__c = 0;
            }
            updatePRSUserAnswersBP.add(pv);
        }
    }*/
    
    /**
    *   function: calculateAnswerWeight
    *   Dynamically calculates answer weight of a given answer
    *   REMARKS: THIS CODE ASSUMES THAT THE WEIGHT AND BASE NUMBER OF THE ANSWERS ARE SORTED DESC
    *   input: List of criteria answers to be weighted
    *          Criteria Threshold (Used to determine weight)
    *          String the answer type (Boolean/Text/Currency/Integer)
    *   return: calculated weight of the answer
    */
    public Double calculateAnswerWeight(List<EUR_CRM_PRS_Question_Criteria__c> prsPossibleAnswers, Double answer, EUR_CRM_PRS_Question__c prsQuestion, String inputRecordType) {
        
        // Groups criteria answers to different list
        List<EUR_CRM_PRS_Question_Criteria__c> lessThanCriteriaAnswerList = new List<sObject>(prsPossibleAnswers.size());
        
        // Determine the field used to store each base number based on the recordtype
        String fieldName = inputRecordType.contains('Currency_Input') ? 'EUR_CRM_Criteria_Threshold_Currency__c' : 'EUR_CRM_Criteria_Threshold_Number__c';
        
        // Determine the weight of answer by looping each criteria answer and checking if it meets the condition
        for(EUR_CRM_PRS_Question_Criteria__c ca: prsPossibleAnswers) {
            Boolean isCriteriaMet = false;
            
            if(prsQuestion.RecordType.DeveloperName.contains(inputRecordType)) {
                if(ca.EUR_CRM_Answer_Condition__c != null) {
                    String condition = ca.EUR_CRM_Answer_Condition__c;
                    condition = condition.subString(condition.indexOf('(')+1, condition.indexOf(')')).trim();
                    
                    if (condition.equalsIgnorecase('=')){
                        isCriteriaMet = (answer == (Double) ca.get(fieldName)) ? true: false;
                    } else if (condition.equalsIgnorecase('!=')){
                        isCriteriaMet = (answer != (Double) ca.get(fieldName)) ? true: false;
                    } else if (condition.equalsIgnorecase('>=')){
                        isCriteriaMet = (answer >= (Double) ca.get(fieldName)) ? true: false;
                    } else if (condition.equalsIgnorecase('>')) {
                        isCriteriaMet = (answer > (Double) ca.get(fieldName)) ? true: false;
                    } else if(condition.equalsIgnorecase('<') || condition.equalsIgnorecase('<=')) {
                        // SPECIAL CASE: For less than condition, need to put in a different list and loop it backwards
                        // To ensure correctness, less than comparison should be done from smallest base number to biggest base number
                        lessThanCriteriaAnswerList.add(0, ca);
                    }
                }
            }
            if(isCriteriaMet) {
                System.debug(ca);
                System.debug(prsQuestion);
                return ca.EUR_CRM_Criteria_Weight__c * prsQuestion.EUR_CRM_Question_Weight__c;
            }
        }
        
        // Checks if there are conditions involving < or <=
        if(lessThanCriteriaAnswerList.size() != 0 && lessThanCriteriaAnswerList[0] != null) {
            for(EUR_CRM_PRS_Question_Criteria__c ca: lessThanCriteriaAnswerList) {
                Boolean isCriteriaMet = false;
                String condition = ca.EUR_CRM_Answer_Condition__c;
                condition = condition.subString(condition.indexOf('(')+1, condition.indexOf(')')).trim();
                if (condition.equalsIgnorecase('<=')) {
                    isCriteriaMet = (answer <= (Double) ca.get(fieldName)) ? true : false;
                } else {
                    isCriteriaMet = (answer < (Double) ca.get(fieldName)) ? true : false;
                }
                
	            if(isCriteriaMet) {
	                System.debug(ca);
	                System.debug(prsQuestion);
	                return ca.EUR_CRM_Criteria_Weight__c * prsQuestion.EUR_CRM_Question_Weight__c;
	            }
            }
        }
        
        System.debug('ERROR!!!!! ' + prsPossibleAnswers);
        return 0;
    }
}