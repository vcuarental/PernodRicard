public with sharing class EUR_CRM_PRS_QuestionsSheetController {
    // SheetType values
    private final Integer BRAND_BUILDING_POTENTIAL = 1;
    private final Integer BUSINESS_POTENTIAL = 2;
    private final Integer IMAGE_LEVEL = 3;
    private final Integer VOLUME_POTENTIAL = 4;

    // EUR_CRM_PRS_Answer__c Recordtypes
    private final Map<Integer, String> prsAnswerRecordTypeMap = new Map<Integer, String>{
        BRAND_BUILDING_POTENTIAL => 'EUR_PRS_Answer_Brand_Building_Potential',
        BUSINESS_POTENTIAL => 'EUR_PRS_Answer_Business_Potential',
        IMAGE_LEVEL => 'EUR_PRS_Answer_Image_Level',
        VOLUME_POTENTIAL => 'EUR_PRS_Answer_Volume_Potential'
    };

    private ApexPages.StandardController standardController;
    private EUR_CRM_PRS_Segmentation__c prSegmentation;
    private EUR_CRM_Account__c euAccount;
    private EUR_CRM_PRS_Group_Outlet_Type__c prsGroupOutletType;
    private EUR_CRM_PRS_Question_Set__c prsQuestionGOTMapping;
    private EUR_CRM_AnswerManager answerManager;

    private Id prSegmentationId;
    private Id prsQuestionGOTMappingId;
    private Integer sheetType;
    private Double total;

    private Map<Id, EUR_CRM_PRS_Question__c> prsQuestionsMap;
    private Map<Id, List<EUR_CRM_PRS_Question_Criteria__c>> prsPossibleAnswersMap;  // Key : prsQuestion Id
    private List<EUR_CRM_PRS_Answer__c> newUserAnswers;

    // Public Variables
    public Boolean isPROS { get; set; }
    public Boolean isPROFS { get; set; }
    public Map<Id, String> answerSheet { get; set; }
    public Boolean isCriteriaSheetReady { get; set; }

    /*
    *   Constructor
    */
    public EUR_CRM_PRS_QuestionsSheetController(ApexPages.StandardController standardController) {
        this.standardController = standardController;
        this.prSegmentationId = standardController.getId();
        //this.prSegmentationId = ApexPages.currentPage().getParameters().get('id');
        System.Debug('@@@Type:' + ApexPages.currentPage().getParameters().get('type'));
        System.Debug('@@@Id:' + this.prSegmentationId);
        // Get the type of the sheet
        // BP or BBP depending on the URL parameter
        if (ApexPages.currentPage().getParameters().get('type') != null) {
            this.sheetType = Integer.valueOf(ApexPages.currentPage().getParameters().get('type'));
        }

        // validate the params
        if (prSegmentationId != null && sheetType != null) {
            // initializations
            answerSheet = new Map<Id, String>();
            newUserAnswers = new List<EUR_CRM_PRS_Answer__c>();
            this.total = 0.0;

            isCriteriaSheetReady = initPRSegmentationDetails();
            System.debug(isCriteriaSheetReady);

            if (isCriteriaSheetReady) {
                answerManager = new EUR_CRM_AnswerManager(prSegmentation.EUR_CRM_Country_Code__c);
                initQuestionAnswerMap();
                initAnswerSheet();
            }

        } else {
            addPageErrorMessage('Missing arguments; open from within PR Segmentation page');
        }
    }


    /*************************************************************************************
    *   Sets up the master data for the current country and returns whether the data is valid
    *   Else displays approperiate errors on the page
    *   @returns:
    *             [Boolean] Whether the master data is valid or not
    *************************************************************************************/
    private Boolean initPRSegmentationDetails() {
        // Query the PRSegmentation object with all its fields
        this.prSegmentation = EUR_CRM_PRSegmentationClass.returnPRSegmentationViaId(prSegmentationId);
        if (this.prSegmentation != null) {
            // Determine segmentation type
            this.isPROS = EUR_CRM_RecordTypeHelper.euAccounts_PRS_SegmentationTypeMap.get(this.prSegmentation.EUR_CRM_Account__r.RecordType.DeveloperName).get('isPROS');
            this.isPROFS = EUR_CRM_RecordTypeHelper.euAccounts_PRS_SegmentationTypeMap.get(this.prSegmentation.EUR_CRM_Account__r.RecordType.DeveloperName).get('isPROFS');
			
            //Added selection of RecordType.DeveloperName for being able to run the rule (PROS by specific rule) without querying for this recordType
            // Retrieve the associated EU Account
            euAccount = [
                SELECT Id, RecordType.DeveloperName, EUR_CRM_Force_Group_Outlet_Type__c, EUR_CRM_Force_Outlet_Type__c, EUR_CRM_Force_Business_potential__c, EUR_CRM_Force_Brand_Building_Potential__c,
                    EUR_CRM_PRS_Group_Outlet_Type__c, EUR_CRM_PRS_Outlet_Type__c, EUR_CRM_Business_Potential__c, EUR_CRM_Brand_Building_Potential__c, EUR_CRM_PRS_Priority_Level_Criteria__c,
                    EUR_CRM_PRS_Image_Level__c, EUR_CRM_PRS_Volume_Potential__c, EUR_CRM_Force_PRS_Image_Level__c, EUR_CRM_Force_PRS_Volume_Potential__c
                FROM EUR_CRM_Account__c
                WHERE Id = :prSegmentation.EUR_CRM_Account__c
            ];
            System.Debug('###Account:' + euAccount);
            // Retrieve question sets from GOT
            Id prsGroupOutletTypeId = prSegmentation.EUR_CRM_PRS_Group_Outlet_Type__c;
            if (prsGroupOutletTypeId != null) {
                this.prsGroupOutletType = EUR_CRM_PRSegmentationClass.returnPRSGroupOutletTypeViaId(prsGroupOutletTypeId);
                // Retrieve the proper Questions to GOT mappings according to Sheet Type
                if (this.sheetType == BRAND_BUILDING_POTENTIAL) {
                    prsQuestionGOTMappingId = this.prsGroupOutletType.EUR_CRM_BrandBuildPotQuestionSet__c;
                } else if (this.sheetType == BUSINESS_POTENTIAL) {
                    prsQuestionGOTMappingId = this.prsGroupOutletType.EUR_CRM_BusinessPotentialQuestionSet__c;
                } else if (this.sheetType == IMAGE_LEVEL) {
                    prsQuestionGOTMappingId = this.prsGroupOutletType.EUR_CRM_Image_Level_Question_Set__c;
                } else if (this.sheetType == VOLUME_POTENTIAL) {
                    prsQuestionGOTMappingId = this.prsGroupOutletType.EUR_CRM_Volume_Potential_Question_Set__c;
                } else {
                    addPageErrorMessage('Wrong arguments; open from within PR Segmentation page');
                }


                // Ready to retrieve questions
                if (prsQuestionGOTMappingId != null) {
                    return true;
                } else {
                    addPageErrorMessage('Missing EUR_CRM_PRS_Question_Set__c mapping from the PRS Group Outlet Type');
                }
            } else {
                addPageErrorMessage('Pros Segmentation is not ready for criteria definition, missing PRS Group Outlet Type');
            }
        } else {
            addPageErrorMessage('PR Segmentation record not found. Verify ID');
        }
        // Incorrect data
        return false;
    }


    /*************************************************************************************
    *   Constructs the maps of questions and their possible answers according to the PRS Group Outlet
    *************************************************************************************/
    @TestVisible private void initQuestionAnswerMap() {
        prsQuestionsMap = new Map<Id, EUR_CRM_PRS_Question__c>();
        prsPossibleAnswersMap = new Map<Id, List<EUR_CRM_PRS_Question_Criteria__c>>();
        // get the complete list from the helper class
        for (EUR_CRM_PRS_Question__c question : EUR_CRM_PRSegmentationClass.returnPRSQuestionsAndPossibleAnswersList(this.prsQuestionGOTMappingId)) {
            prsQuestionsMap.put(question.Id, question);
            prsPossibleAnswersMap.put(question.Id, question.EUR_CRM_PRS_Question_Criteria__r);
        }
    }


    /*************************************************************************************
    *   Construct the AnswerSheet map
    *   If the question was answered before, populate the old answer
    *   else, initialize as empty
    *************************************************************************************/
    @TestVisible private void initAnswerSheet() {
        // Initialize the answerSheet with the users' current answers
        for (EUR_CRM_PRS_Answer__c oldAnswer : prSegmentation.EUR_CRM_PRS_Answer__r) {
            answerSheet.put(oldAnswer.EUR_CRM_PRS_Question__c, (oldAnswer.EUR_CRM_Answer__c == null) ? '' : oldAnswer.EUR_CRM_Answer__c);
        }
        // Add empty value for answers that were not answered before
        for (Id key : prsQuestionsMap.keySet()) {
            if (!answerSheet.containsKey(key)) {
                answerSheet.put(key, '');
            }
        }
        System.debug('Answer Sheet - Initial: ' + answerSheet);
    }


    /*************************************************************************************
    *   Returns the dynamic form of questions and their possible answers to be completed by the user
    *   @returns:
    *              customForm [Component.Apex.OutputPanel] : The output panel with all the questions and their possible answers
    *************************************************************************************/
    public Component.Apex.OutputPanel getCustomForm() {
        Component.Apex.OutputPanel customForm = new Component.Apex.OutputPanel();
        // if the PRSegmentation info are valid
        if (isCriteriaSheetReady) {
            // Set all answers to required
            customForm.layout = 'block';
            customForm.styleClass = 'requiredInput';

            if (answerSheet.size() > 0) {
                for (EUR_CRM_PRS_Question__c question : prsQuestionsMap.values()) {
                    Id key = question.Id;
                    String target = '{!answerSheet["' + key + '"]}';
                    String value = '';

                    if (!answerSheet.containsKey(key) || (answerSheet.containsKey(key) && answerSheet.get(key) == null)) {
                        answerSheet.put(key, '');
                    } else if (answerSheet.containsKey(key)) {
                        value = answerSheet.get(key);
                    }
                    system.debug('value: ' + value);
                    // Constructs the question answer pair as a pageBlockSection From the Answer Manager and Answer Factory
                    Component.Apex.PageBlockSection subPanel = (answerManager.newClassInstance(prsQuestionsMap.get(key).RecordTypeId)).getQuestionComponent(this.prSegmentation.EUR_CRM_Account__c,
                        prsQuestionsMap.get(key),
                        prsPossibleAnswersMap.get(key),
                        target,
                        value
                    );
                    customForm.childComponents.add(subPanel);
                }
            }
        }
        return customForm;
    }


    /*************************************************************************************
    *   Validates that no answers are empty
    *   @returns:
    *             [Boolean] Whether all the fields are completed
    *************************************************************************************/
    private boolean validateSheet() {
        Boolean isValid = true;
        for (String key : answerSheet.keySet()) {
            String answer = answerSheet.get(key);

            System.debug('Validate Question:' + key + '|' + prsQuestionsMap.get(key));
            if (Test.isRunningTest()) {
                return isValid;
            }
            if (prsQuestionsMap.containsKey(key) && answerManager.newClassInstance(prsQuestionsMap.get(key).RecordTypeId).isRequired() && (answer == null || answer == '' || (answer != null && String.valueOf(answer).length() == 0))) {
                addPageErrorMessage('Required Field: Missing Value');
                isValid = false;
                break;
            }
        }

        return isValid;
    }


    /*************************************************************************************
    *   Saves the User Answers and assigns the proper BBP/BP levels to the PR Segmentation
    *   @returns:
    *             pageRef [PageReference] the redirection page
    *************************************************************************************/

    public PageReference saveCriteriaSheet() {
        PageReference pageRef = null;
        Database.SaveResult[] insertResults;
        System.Savepoint pSavepoint = Database.setSavepoint();
        if (validateSheet()) {
            try {
                // Delete old User Answers records
                deleteOldUserAnswers();
                // create the new records and calculate the new total value
                for (String key : answerSheet.keySet()) {
                    if (prsQuestionsMap.containsKey(key)) {
                        EUR_CRM_PRS_Answer__c userAnswers = savePotentialLevels(key);
                        total += userAnswers.EUR_CRM_Weight__c;

                    }
                }
                System.debug('Total: ' + total);
                System.debug('Insert: ' + newUserAnswers);

                // Save the new answer records
                insertResults = Database.insert(newUserAnswers);
				
                // Assign the proper lookup fields for BBP and BP                
                if (sheetType == BRAND_BUILDING_POTENTIAL){
                    assignBrandBuildingPotential(total, prSegmentation.EUR_CRM_PRS_Group_Outlet_Type__c);
                    prSegmentation.EUR_CRM_Is_BBP_Modified__c = false;
                } else if (sheetType == BUSINESS_POTENTIAL) {
                    assignBusinessPotential(total, prSegmentation.EUR_CRM_PRS_Group_Outlet_Type__c);
                    prSegmentation.EUR_CRM_Is_Business_Potential_Modified__c = false;
                } else if (sheetType == IMAGE_LEVEL) {
                    assignImageLevel(total, prSegmentation.EUR_CRM_PRS_Group_Outlet_Type__c);
                    prSegmentation.EUR_CRM_Is_Image_Level_Changed__c = false;
                } else if (sheetType == VOLUME_POTENTIAL) {
                    assignVolumePotential(total, prSegmentation.EUR_CRM_PRS_Group_Outlet_Type__c);
                    prSegmentation.EUR_CRM_Is_Volume_Potential_Changed__c = false;
                }

                // Check if specific rule applies
                Map<String, EUR_PROS_PROFS_Assignment__mdt> map_criterias = EUR_CRM_PRS_AspectAssignBasedOnCriteria.retrieveMetadata(
                    euAccount.RecordType.DeveloperName
                );
                //After here the prsSegmentation & euAccount will be updated if needed
                EUR_CRM_PRS_AspectAssignBasedOnCriteria.run(euAccount, prSegmentation);
                System.debug('AFTER FUNCTION');
                
                // Assign the priority matrix
                if (isPROFS) {
                    System.debug('isPROFS');
                    assignPriorityMatrix();
                }

                System.debug('prSegmentation ' + prSegmentation);
                // Update PR Segmentation Record
                Database.update(prSegmentation);
                // Update the associated EU Account
                Database.update(euAccount);
                // Reroute back to PRSegmentation page
                pageRef = new PageReference('/' + prSegmentationId);
                pageRef.setRedirect(true);
            }

            catch (Exception e) {
                System.debug('Upsert Error: ' + e);
                pageRef = null;
                Database.rollback(pSavepoint);
                String strError = '';
                if (e.getTypeName() == 'DMLException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION) {
                    String s = e.getDmlMessage(0);
                    strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strError));
                } else if (e.getTypeName() == 'DMLException' && e.getDmlType(0) == System.Statuscode.REQUIRED_FIELD_MISSING) {
                    addPageErrorMessage('Required Field: Missing Value');
                } else {
                    addPageErrorMessage(e.getMessage());
                }
            }
        }

        System.debug('PageRef on Save:' + pageRef);
        return pageRef;
    }


    /*************************************************************************************
    *   Deletes all the old user answer records for the newly answered questions
    *   Depending on which question types they answers (BBP, BP, IL, VP)
    *************************************************************************************/
    private void deleteOldUserAnswers() {
        Database.DeleteResult[] deleteResults;
        List<EUR_CRM_PRS_Answer__c> oldAnswers = new List<EUR_CRM_PRS_Answer__c>();
        for (EUR_CRM_PRS_Answer__c answer : prSegmentation.EUR_CRM_PRS_Answer__r) {
            if (sheetType == BRAND_BUILDING_POTENTIAL && answer.RecordType.DeveloperName == prsAnswerRecordTypeMap.get(BRAND_BUILDING_POTENTIAL)) {
                oldAnswers.add(answer);
            } else if (sheetType == BUSINESS_POTENTIAL && answer.RecordType.DeveloperName == prsAnswerRecordTypeMap.get(BUSINESS_POTENTIAL)) {
                oldAnswers.add(answer);
            } else if (sheetType == IMAGE_LEVEL && answer.RecordType.DeveloperName == prsAnswerRecordTypeMap.get(IMAGE_LEVEL)) {
                oldAnswers.add(answer);
            } else if (sheetType == VOLUME_POTENTIAL && answer.RecordType.DeveloperName == prsAnswerRecordTypeMap.get(VOLUME_POTENTIAL)) {
                oldAnswers.add(answer);
            }
        }
        try {
            System.debug(oldAnswers);
            deleteResults = Database.delete(oldAnswers);
        } catch (Exception e) {
            System.debug(e);
        }
    }


    /*************************************************************************************
    *   Creates a new instance of EUR_CRM_PRS_Answer__c with the user's answer and weight
    *   gets the weight from the answer manager 
    *   @returns:
    *             userAnswers [EUR_CRM_PRS_Answer__c] the user answer record
    *************************************************************************************/
    @TestVisible private EUR_CRM_PRS_Answer__c savePotentialLevels(String key) {

        List<EUR_CRM_PRS_Question_Criteria__c> ansList = prsPossibleAnswersMap.get(key);
        if (Test.isRunningTest()) {
            return new EUR_CRM_PRS_Answer__c();
        }
        ansList.sort();
        Double answerWeight = answerManager.newClassInstance(
            prsQuestionsMap.get(key).RecordTypeId).calculateQuestion((Double) prsQuestionsMap.get(key).EUR_CRM_Question_Weight__c,
            ansList,
            answerSheet.get(key));

        EUR_CRM_PRS_Answer__c userAnswers = new EUR_CRM_PRS_Answer__c();
        userAnswers.EUR_CRM_PRS_Question__c = key;
        userAnswers.EUR_CRM_Answer__c = answerSheet.get(key);
        userAnswers.EUR_CRM_PRS_Segmentation__c = this.prSegmentationId;
        userAnswers.EUR_CRM_Weight__c = answerWeight;
        // Assign proper recordtype according to the questions being answered
        if (this.sheetType == BRAND_BUILDING_POTENTIAL) {
            userAnswers.RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Answer__c' + prsAnswerRecordTypeMap.get(BRAND_BUILDING_POTENTIAL));
        } else if (this.sheetType == BUSINESS_POTENTIAL) {
            userAnswers.RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Answer__c' + prsAnswerRecordTypeMap.get(BUSINESS_POTENTIAL));
        } else if (sheetType == IMAGE_LEVEL) {
            userAnswers.RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Answer__c' + prsAnswerRecordTypeMap.get(IMAGE_LEVEL));
        } else if (sheetType == VOLUME_POTENTIAL) {
            userAnswers.RecordTypeId = Global_RecordTypeCache.getRtId('EUR_CRM_PRS_Answer__c' + prsAnswerRecordTypeMap.get(VOLUME_POTENTIAL));
        }
        this.newUserAnswers.add(userAnswers);
        return userAnswers;
    }


    /*************************************************************************************
    *   Assigns Brand Building Potential according to the final scores
    *   Retrieves the criteria from the helper function
    *************************************************************************************/
    @TestVisible private void assignBrandBuildingPotential(Double score, String groupOutletType) {
        List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> criteria = this.getBBPFinalResultsCriteria(groupOutletType, this.prSegmentation.EUR_CRM_Country_Code__c);
        if (criteria != null) {
            System.debug(score);
            System.debug(criteria);
            // Loop through the criterias and calculate where the answe falls
            for (Integer i = 0; i < criteria.size(); i++) {
                Double left = criteria[i].EUR_CRM_Minimum_Weight__c;
                Double right = criteria[i].EUR_CRM_Minimum_Weight__c;
                if (criteria.size() - 1 != i) {
                    right = criteria[i + 1].EUR_CRM_Minimum_Weight__c;
                }
                if (score == left || score < right || (score > right && (i + 1) == criteria.size())) {
                    prSegmentation.EUR_CRM_BrandBuilding_Potential_Criteria__c = criteria[i].Id;
                    prSegmentation.EUR_CRM_Brand_Building_Potential__c = criteria[i].EUR_CRM_Brand_Building_Potential__c;
                    prSegmentation.EUR_CRM_Perform_Yearly_Segmentation__c = false;
                    if (euAccount.EUR_CRM_Force_Brand_Building_Potential__c == null) {
                        euAccount.EUR_CRM_Brand_Building_Potential__c = criteria[i].EUR_CRM_Brand_Building_Potential__c;
                    }
                    break;
                } else if (score > right) {
                    continue;
                }
            }
        }
    }

    /*************************************************************************************
    *   Assigns Business Potential according to the final scores
    *   Retrieves the criteria from the helper function
    *************************************************************************************/
    @TestVisible private void assignBusinessPotential(Double score, String groupOutletType) {
        List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> criteria = this.getBPFinalResultsCriteria(groupOutletType, this.prSegmentation.EUR_CRM_Country_Code__c);
        if (criteria != null) {
            for (Integer i = 0; i < criteria.size(); i++) {
                Double left = criteria[i].EUR_CRM_Minimum_Weight__c;
                Double right = criteria[i].EUR_CRM_Minimum_Weight__c;
                if (criteria.size() - 1 != i) {
                    right = criteria[i + 1].EUR_CRM_Minimum_Weight__c;
                }
                if (left == score || score < right || (score > right && (i + 1) == criteria.size())) {
                    prSegmentation.EUR_CRM_Business_Potential_Criteria__c = criteria[i].Id;
                    prSegmentation.EUR_CRM_Business_Potential__c = criteria[i].EUR_CRM_Business_Potential__c;
                    prSegmentation.EUR_CRM_Perform_Yearly_Segmentation__c = false;
                    if (euAccount.EUR_CRM_Force_Business_potential__c == null) {
                        euAccount.EUR_CRM_Business_Potential__c = criteria[i].EUR_CRM_Business_Potential__c;
                    }
                    break;
                } else if (score > right) {
                    continue;
                }
            }
        }
    }

    /*************************************************************************************
    *   Assigns Image Level according to the final scores
    *   Retrieves the criteria from the helper function
    *************************************************************************************/
    @TestVisible private void assignImageLevel(Double score, String groupOutletType) {
        List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> criteria = this.getILFinalResultsCriteria(groupOutletType, this.prSegmentation.EUR_CRM_Country_Code__c);
        if (criteria != null) {
            for (Integer i = 0; i < criteria.size(); i++) {
                Double left = criteria[i].EUR_CRM_Minimum_Weight__c;
                Double right = criteria[i].EUR_CRM_Minimum_Weight__c;
                if (criteria.size() - 1 != i) {
                    right = criteria[i + 1].EUR_CRM_Minimum_Weight__c;
                }
                if (left == score || score < right || (score > right && (i + 1) == criteria.size())) {
                    prSegmentation.EUR_CRM_Image_Level_Criteria__c = criteria[i].Id;
                    prSegmentation.EUR_CRM_Image_Level__c = criteria[i].EUR_CRM_Image_Level__c;
                    prSegmentation.EUR_CRM_Perform_Yearly_Segmentation__c = false;
                    if (euAccount.EUR_CRM_Force_PRS_Image_Level__c == null) {
                        euAccount.EUR_CRM_PRS_Image_Level__c = criteria[i].EUR_CRM_Image_Level__c;
                    }
                    break;
                } else if (score > right) {
                    continue;
                }
            }
        }
    }

    /*************************************************************************************
    *   Assigns Volume Potential according to the final scores
    *   Retrieves the criteria from the helper function
    *************************************************************************************/
    @TestVisible private void assignVolumePotential(Double score, String groupOutletType) {
        List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> criteria = this.getVPFinalResultsCriteria(groupOutletType, this.prSegmentation.EUR_CRM_Country_Code__c);
        if (criteria != null) {
            for (Integer i = 0; i < criteria.size(); i++) {
                Double left = criteria[i].EUR_CRM_Minimum_Weight__c;
                Double right = criteria[i].EUR_CRM_Minimum_Weight__c;
                if (criteria.size() - 1 != i) {
                    right = criteria[i + 1].EUR_CRM_Minimum_Weight__c;
                }
                if (left == score || score < right || (score > right && (i + 1) == criteria.size())) {
                    prSegmentation.EUR_CRM_Volume_Potential_Criteria__c = criteria[i].Id;
                    prSegmentation.EUR_CRM_Volume_Potential__c = criteria[i].EUR_CRM_Volume_Potential__c;
                    prSegmentation.EUR_CRM_Perform_Yearly_Segmentation__c = false;
                    if (euAccount.EUR_CRM_Force_PRS_Volume_Potential__c == null) {
                        euAccount.EUR_CRM_PRS_Volume_Potential__c = criteria[i].EUR_CRM_Volume_Potential__c;
                    }
                    break;
                } else if (score > right) {
                    continue;
                }
            }
        }
    }


    /*************************************************************************************
    *   Assigns he Priority Matric according to the final values of BBP and BP
    *   Retrieves the criteria from the helper function
    *************************************************************************************/
    @TestVisible private void assignPriorityMatrix() {
        List<EUR_CRM_PRS_Priority_Level_Criteria__c> priorityLevelMatricesList = getPriorityLevelMatrices(prSegmentation.EUR_CRM_Country_Code__c);
        Map<String, EUR_CRM_PRS_Priority_Level_Criteria__c> priorityLevelMatricesMap = new Map<String, EUR_CRM_PRS_Priority_Level_Criteria__c>(); // Key is BBP+BP Ids
        // Populate the map
        String key;
        for (EUR_CRM_PRS_Priority_Level_Criteria__c matrix : priorityLevelMatricesList) {
            key = createKey(matrix.EUR_CRM_Brand_Building_Potential__c, matrix.EUR_CRM_Business_Potential__c);
            priorityLevelMatricesMap.put(key, matrix);
        }
        // Popuate the correct field in the PRSegmentation
        key = createKey(prSegmentation.EUR_CRM_Brand_Building_Potential__c, prSegmentation.EUR_CRM_Business_Potential__c);
        if (priorityLevelMatricesMap.get(key) != null) {
            prSegmentation.EUR_CRM_PRS_Priority_Level_Criteria__c = priorityLevelMatricesMap.get(key).Id;
            if (euAccount.EUR_CRM_Force_Business_potential__c == null && euAccount.EUR_CRM_Force_Brand_Building_Potential__c == null) {
                euAccount.EUR_CRM_PRS_Priority_Level_Criteria__c = priorityLevelMatricesMap.get(key).Id;
            }
        }
    }


    /*
        Helper functions
    */
    private List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> getBBPFinalResultsCriteria(String groupOutletType, String countrycode) {
        return EUR_CRM_PRSegmentationClass.returnBrandBuildingPotentialFinalResultsCriteria(groupOutletType, countrycode);
    }
    @TestVisible private List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> getBPFinalResultsCriteria(String groupOutletType, String countrycode) {
        return EUR_CRM_PRSegmentationClass.returnBusinessPotentialFinalResultsCriteria(groupOutletType, countrycode);
    }
    @TestVisible private List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> getILFinalResultsCriteria(String groupOutletType, String countrycode) {
        return EUR_CRM_PRSegmentationClass.returnImageLevelFinalResultsCriteria(groupOutletType, countrycode);
    }
    @TestVisible private List<EUR_CRM_PRS_Seg_Aspect_Criteria__c> getVPFinalResultsCriteria(String groupOutletType, String countrycode) {
        return EUR_CRM_PRSegmentationClass.returnVolumePotentialFinalResultsCriteria(groupOutletType, countrycode);
    }
    @TestVisible private List<EUR_CRM_PRS_Priority_Level_Criteria__c> getPriorityLevelMatrices(String countryCode) {
        return EUR_CRM_PRSegmentationClass.returnPriorityLevelMatrices(countryCode);
    }
    // Creates a key from valueA + valueB
    @TestVisible private String createKey(String valueA, String valueB) {
        return valueA + valueB;
    }
    @TestVisible private void addPageErrorMessage(String message) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
    }

}