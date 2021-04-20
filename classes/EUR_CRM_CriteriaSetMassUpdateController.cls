/*
   Updates the Volume and Image Levels values inside PROS Segmentations
   According to the updated weightings of the criterias
*/

global class EUR_CRM_CriteriaSetMassUpdateController implements Database.Batchable<sObject>, Database.Stateful{  
    
    private Double answerWeight;
    private List<EUR_CRM_Group_Outlet_Type__c> groupOutletTypeInfoList;
    private List<EUR_CRM_Pros_Image_Level__c> newImageLevels;  
    
    public Set<Id> cSetId;
    public Map<Id, EUR_CRM_Pros_Segmentation__c> prosSegIdMap;
    
    public List<EUR_CRM_Pros_Image_Level__c> updateListProsSegImgLevel;
    public List<EUR_CRM_Pros_Volume_Potential__c> updateListProsSegVolLevel;
    String countryCode; 
    public String criteriaSetLevel;
    
    global List<EUR_CRM_Criteria_Set__c> csetList;
    global List<EUR_CRM_Criteria_Threshold__c> criteriaThresholdList;
    

    /*****************************************************************************************
    *   Constructor. Sets the country Code to retrieve PROS Segmentation from that country alone
    *   and initializes the arrays
    *   @param: 
    *        CountryCode [String] : The 2 letter abbreviation code of the country 
    *****************************************************************************************/
    global EUR_CRM_CriteriaSetMassUpdateController (String criteriaSetLevel){
        this.criteriaSetLevel = criteriaSetLevel;
        cSetId = new Set<Id>();
        newImageLevels = new List<EUR_CRM_Pros_Image_Level__c>();
        updateListProsSegImgLevel = new List<EUR_CRM_Pros_Image_Level__c>();
    }
    
    /*****************************************************************************************
    *   Second Constructor. Sets the country Code to retrieve PROS Segmentation from that country alone
    *   as well as the criteria set (whether Image or volume)
    *   @param: 
    *        criteriaSetLevel [String] : whether Volume or Image, depending on the button clicked
    *        CountryCode [String] : The 2 letter abbreviation code of the country 
    *****************************************************************************************/
    global EUR_CRM_CriteriaSetMassUpdateController (String criteriaSetLevel,String countryCode){
        this.criteriaSetLevel = criteriaSetLevel;
        cSetId = new Set<Id>();
        newImageLevels = new List<EUR_CRM_Pros_Image_Level__c>();
        updateListProsSegImgLevel = new List<EUR_CRM_Pros_Image_Level__c>();
        this.countryCode = countryCode;
    }
    
    /*****************************************************************************************
    *   Batch start function
    *   Queries all criteria thresholds records with updated criterias depending on the specified criteriaSetLevel
    *   @param: 
    *        BC [BatchContext] : Fed automatically, this function is not called explicitly
    *****************************************************************************************/
    global Database.QueryLocator start(Database.BatchableContext BC){  
        String query1 = 'SELECT Id, EUR_CRM_Criteria_Set__c, EUR_CRM_isChanged__c FROM EUR_CRM_Criteria_Threshold__c ' + 
                            'WHERE EUR_CRM_isChanged__c = true AND EUR_CRM_Criteria_Set__r.RecordType.DeveloperName LIKE :criteriaSetLevel';
        if(countryCode!= null){
             query1 +=' AND eur_crm_criteria_set__r.eur_crm_country_code__c =\'' + countryCode+'\'';
        }
        
        List<EUR_CRM_Criteria_Threshold__c> criteriaSets = Database.query(query1);
        
        system.debug('***criteriaSets: ' + criteriaSets);
        
        prosSegIdMap = new Map<Id, EUR_CRM_Pros_Segmentation__c>();
        groupOutletTypeInfoList = new List<EUR_CRM_Group_Outlet_Type__c>();
        updateListProsSegImgLevel = new List<EUR_CRM_Pros_Image_Level__c>();
        updateListProsSegVolLevel = new List<EUR_CRM_Pros_Volume_Potential__c>();
        
        Set<Id> grpOutletIds = new Set<Id>();
        csetList = new List<EUR_CRM_Criteria_Set__c>();
        criteriaThresholdList = new List<EUR_CRM_Criteria_Threshold__c>();
        
        // Create a set of all criteria Ids
        // AND a global list of all criteria thresholds
        for(EUR_CRM_Criteria_Threshold__c ct : criteriaSets){
            cSetId.add(ct.EUR_CRM_Criteria_Set__c);
            criteriaThresholdList.add(ct);
        }
        
        // If criterias were updated retrieve the group outlet types 
        if(cSetId.size() > 0){
            csetList = [SELECT Id, RecordType.DeveloperName FROM EUR_CRM_Criteria_Set__c WHERE Id IN: cSetId];
            system.debug('***csetList' + csetList);
            if(criteriaSetLevel == '%Image%'){
                groupOutletTypeInfoList = [SELECT Id, EUR_CRM_Group_Outlet_Name__c, EUR_CRM_Image_Criteria_Set__r.Id 
                                            FROM EUR_CRM_Group_Outlet_Type__c WHERE EUR_CRM_Image_Criteria_Set__r.Id IN :cSetId];
            }
            else if(criteriaSetLevel == '%Volume%'){
                groupOutletTypeInfoList = [SELECT Id, EUR_CRM_Group_Outlet_Name__c, EUR_CRM_Volume_Criteria_Set__r.Id 
                                            FROM EUR_CRM_Group_Outlet_Type__c WHERE EUR_CRM_Volume_Criteria_Set__r.Id IN :cSetId];
            }
        }
        
        if(groupOutletTypeInfoList.size() > 0){
            // Get unique Ids of Group Outlet Types
            for (EUR_CRM_Group_Outlet_Type__c got : groupOutletTypeInfoList){
                grpOutletIds.add(got.Id);
            }
            //system.debug('***grpOutletIds ' + grpOutletIds.size() + '  ' + grpOutletIds);
        }
        
        // Retrieve all the PROS Segmentations to be updated
        String query = 'SELECT Id, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Total_Image_Level_Weight__c, EUR_CRM_Total_Volume_Weight__c ' + 
                        'FROM EUR_CRM_Pros_Segmentation__c  ' + 
                        ' WHERE EUR_CRM_Group_Outlet_Type__c IN :grpOutletIds';
        system.debug([SELECT Id, EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Total_Image_Level_Weight__c, EUR_CRM_Total_Volume_Weight__c FROM EUR_CRM_Pros_Segmentation__c WHERE EUR_CRM_Group_Outlet_Type__c IN :grpOutletIds]);
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
        system.debug('entered execute');
        updateCriteriaSets((List<EUR_CRM_Pros_Segmentation__c>) scope);
    }


    /*****************************************************************************************
    *   Batch finish function
    *   Updates the list of Criteria Sets AND Criteria Thresholds
    *   Then sends an email notification to the user who started the batch on its completion
    *   @param:
    *        BC [BatchContext] : Fed automatically, this function is not called explicitly   
    *****************************************************************************************/   
    global void finish(Database.BatchableContext BC){
        
        //update level Criteria Set
        for (EUR_CRM_Criteria_Set__c cs : csetList){
            cs.EUR_CRM_Last_Mass_Update_Date__c = Datetime.now();
        }
        update csetList;
        
        // Unchecks isChanged flagged for criteria thresholds
        for(EUR_CRM_Criteria_Threshold__c ct :criteriaThresholdList){
            ct.EUR_CRM_isChanged__c = false;
        }
        update criteriaThresholdList;
        
        EUR_CRM_BatchApexUtilityClass.sendBatchResultEmail(UserInfo.getUserId(),BC.getJobId(), new String[] {});
    }

    /*****************************************************************************************
    *  
    *   @param: 
    *        prosSegList [List<EUR_CRM_Pros_Segmentation__c>] : List of PROS Segmentations to be updated as specified by the scope in the execute function
    *****************************************************************************************/
    public void updateCriteriaSets(List<EUR_CRM_Pros_Segmentation__c> prosSegList){
        system.debug('entered updateCriteriaSets');
        
        // Populate the PROS Segmentation map
        if (prosSegList.size() > 0){
            for (EUR_CRM_Pros_Segmentation__c eupros : prosSegList){
                prosSegIdMap.put(eupros.Id, eupros);
            }
            system.debug('***prosSegIdMap ' + prosSegIdMap.size() + '  ' + prosSegIdMap);
        }
        
        // Call the respective calculation functions
        if (groupOutletTypeInfoList.size() > 0){

            if(criteriaSetLevel == '%Image%'){
                calculateBoolean();
                calculateInteger();
                calculatePicklist();
                calculateCurrency();
                calculateText();
            }else if(criteriaSetLevel == '%Volume%'){
                calculateBooleanVol();
                calculateIntegerVol();
                calculatePicklistVol();
                calculateCurrencyVol();
                calculateTextVol();
            }

            //Update Image/Volume Pros
            if(criteriaSetLevel == '%Image%'){
                system.debug('***updateListProsSegImgLevel.size(): ' + updateListProsSegImgLevel.size());
                
                if(updateListProsSegImgLevel.size() > 0){
                    
                    // Remove duplicates from list of pros image level
                    Set<EUR_CRM_Pros_Image_Level__c> tempProsImageLevelSet = new Set<EUR_CRM_Pros_Image_Level__c>();
                    tempProsImageLevelSet.addAll(updateListProsSegImgLevel);
                    List<EUR_CRM_Pros_Image_Level__c> updateListProsSegImgLevelNoDuplication = new List<EUR_CRM_Pros_Image_Level__c>();
                    updateListProsSegImgLevelNoDuplication.addAll(tempProsImageLevelSet);
                    
                    System.debug(updateListProsSegImgLevelNoDuplication);
                    
                    try{
                        // Update Pros Image Level
                        EUR_CRM_CommonRoutine.dmlWithPartialSuccess('update', updateListProsSegImgLevelNoDuplication);
                        
                        // Update PROS Segmentation and Image Level Threshold (if also changed)
                        EUR_CRM_ImageLevelThresholdMassUpdate.processImageLevelThreshold(prosSegList);                        
                    }catch(DmlException e){
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, '' + e));
                    }
                }
            }
            else if(criteriaSetLevel == '%Volume%'){
                system.debug('***updateListProsSegVolLevel.size(): ' + updateListProsSegVolLevel.size());
                if(updateListProsSegVolLevel.size() > 0){
                    
                    // Remove duplicates from list of volume potential
                    Set<EUR_CRM_Pros_Volume_Potential__c> tempProsVolumePotentialSet = new Set<EUR_CRM_Pros_Volume_Potential__c>();
                    tempProsVolumePotentialSet.addAll(updateListProsSegVolLevel);
                    List<EUR_CRM_Pros_Volume_Potential__c> updateListProsSegVolLevelNoDuplication = new List<EUR_CRM_Pros_Volume_Potential__c>();
                    updateListProsSegVolLevelNoDuplication.addAll(tempProsVolumePotentialSet);
                    
                    System.debug(updateListProsSegVolLevelNoDuplication);
                    
                    try{
                        // Update Pros Volume Potential
                        EUR_CRM_CommonRoutine.dmlWithPartialSuccess('update', updateListProsSegVolLevelNoDuplication);
                        
                        // Update PROS Segmentation and Volume Potential Threshold (if also changed)
                        EUR_CRM_VolumeLevelThresholdMassUpdate.processVolumeLevelThreshold(prosSegList);                        
                    }catch(DmlException e){
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, '' + e));
                    }
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

        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapBool = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();
        Map<Id, EUR_CRM_Criteria_Threshold__c>  criteriaThresholdMap = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        
        // Retrieve all Criteria Sets (EU) that contain Boolean Criteria Thresholds
        ctList = [SELECT Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c FROM EUR_CRM_Criteria_Threshold__c
                    WHERE EUR_CRM_Criteria_Set__c = :cSetId 
                    AND Recordtype.DeveloperName = 'EUR_CRM_Boolean'];

        system.debug('ctListDevName' + ctList.size()); 
        
        // Populate the Id set and Map
        for (EUR_CRM_Criteria_Threshold__c crThrs : ctList){
            ctIds.add(crThrs.Id);
            criteriaThresholdMap.put(crThrs.Id, crThrs);
        }
        
        // List to update
        newImageLevels  = new List<EUR_CRM_Pros_Image_Level__c>();
        
        if(ctIds.size()>0){
            newImageLevels = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Weight__c,
                            EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c, EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName
                            FROM EUR_CRM_Pros_Image_Level__c
                            WHERE EUR_CRM_Pros_Segmentation__c IN :prosSegIdMap.keyset()
                            AND EUR_CRM_Criteria_Threshold__c IN :ctIds
                            ORDER BY EUR_CRM_Weight__c];
        }

        // Get all the answers for the retrieved questions
        List<EUR_CRM_Criteria_Answer__c> cAnswerListTempBool = [SELECT Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Value__c,EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c
                                                                FROM EUR_CRM_Criteria_Answer__c
                                                                WHERE EUR_CRM_Criteria_Threshold__c IN :ctIds
                                                                ORDER BY EUR_CRM_Base_Integer__c desc]; 
        // Create a map between each question and its answers                                
        for (EUR_CRM_Criteria_Answer__c ans: cAnswerListTempBool){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMapBool.containsKey(key)) ? cAnswerMapBool.get(key) : new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMapBool.put(key,ansList);
        }
        
        Double answerWeight = 0;       
        system.debug('criteriaThresholdMap' + criteriaThresholdMap);

        // Recalculate the PROS's answer weight
        for (EUR_CRM_Pros_Image_Level__c pros : newImageLevels){          
            // Get the weight of each question
            for (EUR_CRM_Criteria_Answer__c ca : cAnswerMapBool.get(pros.EUR_CRM_Criteria_Threshold__c) ){
                // If the value of the answer is null set it to false
                ca.EUR_CRM_Value__c = (ca.EUR_CRM_Value__c!=null) ? ca.EUR_CRM_Value__c : '';
                // Check if the answer is correct
                if (ca.EUR_CRM_Value__c.equalsIgnorecase(pros.EUR_CRM_Answer__c)){
                    answerWeight = ca.EUR_CRM_Weight__c * criteriaThresholdMap.get(pros.EUR_CRM_Criteria_Threshold__c).EUR_CRM_Weight__c;
                } 
            }
            pros.EUR_CRM_Weight__c = answerWeight/100;
            updateListProsSegImgLevel.add(pros);
        }
    }
    

    /*****************************************************************************************
    *   
    *   Calculate Image Integer scores
    * 
    *****************************************************************************************/
    public void calculateInteger(){

        Double answerWeight = 0;
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Pros_Image_Level__c> updateListProsSegImgLevelInt = null;
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        Map <Id,EUR_CRM_Criteria_Threshold__c >  criteriaThresholdMap = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        
        updateListProsSegImgLevelInt = new List<EUR_CRM_Pros_Image_Level__c>();
        
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMap = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();
        
        // Get Criteria thresholds which answers are in integer fromat
        ctList = [SELECT Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c 
                    FROM EUR_CRM_Criteria_Threshold__c
                    WHERE EUR_CRM_Criteria_Set__c =: cSetId
                    AND Recordtype.DeveloperName = 'EUR_CRM_Integer_Input'];

        system.debug('***ctListDevNameInt: ' + ctList.size()); 
        
        for (EUR_CRM_Criteria_Threshold__c e: ctList){
            ctIds.add(e.Id);
            criteriaThresholdMap.put(e.Id, e);
        }
        
        if(ctIds.size()>0){
            // Get all Image levels to be updated
            updateListProsSegImgLevelInt = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_Statement__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,
                                            EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName, EUR_CRM_Weight__c
                                            FROM EUR_CRM_Pros_Image_Level__c
                                            WHERE EUR_CRM_Pros_Segmentation__c IN :prosSegIdMap.keyset()
                                            AND EUR_CRM_Criteria_Threshold__c IN :ctIds 
                                            ORDER BY EUR_CRM_Weight__c];
        }
        // List of the answers for the retrieved questions
        List<EUR_CRM_Criteria_Answer__c> cAnswerListTemp = [SELECT Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, 
                                                                EUR_CRM_Value__c, EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c 
                                                                FROM EUR_CRM_Criteria_Answer__c
                                                                WHERE EUR_CRM_Criteria_Threshold__c IN :ctIds
                                                                ORDER BY EUR_CRM_Weight__c desc, EUR_CRM_Base_Integer__c desc]; 
        
        // Map criteria thresholds to answers                                                    
        for (EUR_CRM_Criteria_Answer__c ans : cAnswerListTemp){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMap.containsKey(key)) ? cAnswerMap.get(key) : new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMap.put(key,ansList);
        }

        for (EUR_CRM_Pros_Image_Level__c pros : updateListProsSegImgLevelInt){
            Double answer;
            try{
                String a = pros.EUR_CRM_Answer__c;
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
                cAnswerMap.get(pros.EUR_CRM_Criteria_Threshold__c),
                answer,
                criteriaThresholdMap.get(pros.EUR_CRM_Criteria_Threshold__c),
                criteriaThresholdMap.get(pros.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName
            );
            
            pros.EUR_CRM_Weight__c = answerWeight/100;
            updateListProsSegImgLevel.add(pros);
        }
    }
    
    public void calculatePicklist(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapPick = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();
        List<EUR_CRM_Pros_Image_Level__c> updateListProsSegImgLevelPick = null;
        
        system.debug('ctListDevNameInt' + ctList.size()); 
        Double answerWeight = 0;
        
        Map <Id,EUR_CRM_Criteria_Threshold__c >  thresholdWeightMap = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        for (EUR_CRM_Criteria_Threshold__c e: [SELECT Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c FROM EUR_CRM_Criteria_Threshold__c
                                                    WHERE EUR_CRM_Criteria_Set__c =: cSetId  AND Recordtype.DeveloperName =:'EUR_CRM_Picklist']){
            ctIds.add(e.Id);
            thresholdWeightMap.put(e.Id, e);
            
        }
        system.debug('prosSegIdMap' + prosSegIdMap);
        system.debug('prosSegIdMap2' + prosSegIdMap.keyset());
        
        updateListProsSegImgLevelPick = new List<EUR_CRM_Pros_Image_Level__c>();
        
        if(ctIds.size()>0){
        updateListProsSegImgLevelPick = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, 
                                            EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName 
                                            FROM EUR_CRM_Pros_Image_Level__c
                                            WHERE EUR_CRM_Pros_Segmentation__c IN :prosSegIdMap.keyset()
                                            AND EUR_CRM_Criteria_Threshold__c IN :ctIds ORDER BY EUR_CRM_Weight__c];
          }                          
        List<EUR_CRM_Criteria_Answer__c> cAnswerListTempPick = [SELECT Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, 
                                                                    EUR_CRM_Value__c,EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c 
                                                                    FROM EUR_CRM_Criteria_Answer__c
                                                                    WHERE EUR_CRM_Criteria_Threshold__c IN :ctIds
                                                                    ORDER BY EUR_CRM_Base_Integer__c desc ];     
        
        for (EUR_CRM_Criteria_Answer__c ans: cAnswerListTempPick){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMapPick.containsKey(key))?cAnswerMapPick.get(key):new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMapPick.put(key,ansList);
        }
                        
        for (EUR_CRM_Pros_Image_Level__c p : updateListProsSegImgLevelPick){
            EUR_CRM_Pros_Image_Level__c prosImg = new EUR_CRM_Pros_Image_Level__c();
            prosImg.EUR_CRM_Criteria_Threshold__c = p.EUR_CRM_Criteria_Threshold__c;
            prosImg.EUR_CRM_Pros_Segmentation__c = p.EUR_CRM_Pros_Segmentation__c;
            prosImg.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
            prosImg.id = p.id;
        
            for (EUR_CRM_Criteria_Answer__c ca : cAnswerMapPick.get(p.EUR_CRM_Criteria_Threshold__c)){                      
                if (thresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Picklist')){
                    ca.EUR_CRM_Value__c = (ca.EUR_CRM_Value__c!=null)?ca.EUR_CRM_Value__c:'';
                    if (ca.EUR_CRM_Value__c.equalsIgnorecase(p.EUR_CRM_Answer__c)){
                        answerWeight = ca.EUR_CRM_Weight__c * thresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c).EUR_CRM_Weight__c;
                    }   
                }
            }
            prosImg.EUR_CRM_Weight__c = answerWeight/100;
            updateListProsSegImgLevel.add(prosImg);
        }
    }
    
    public void calculateCurrency(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapCurr = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();
        List<EUR_CRM_Pros_Image_Level__c> updateListProsSegImgLevelCurr = null;
        
        ctList = [SELECT Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c 
                    FROM EUR_CRM_Criteria_Threshold__c
                    WHERE EUR_CRM_Criteria_Set__c =: cSetId  AND Recordtype.DeveloperName =:'EUR_CRM_Currency_Input'];
                    
        system.debug('ctListDevNameCurr' + ctList.size()); 
        Double answerWeight = 0;
        Map <Id,EUR_CRM_Criteria_Threshold__c >  thresholdWeightMap = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        
        for (EUR_CRM_Criteria_Threshold__c e: ctList){
            //system.debug('eeeeee' + e.RecordType.DeveloperName);
            ctIds.add(e.Id);
            thresholdWeightMap.put(e.Id, e);
    
        }
        
        updateListProsSegImgLevelCurr = new List<EUR_CRM_Pros_Image_Level__c>();
        
        if(ctIds.size()>0){
        updateListProsSegImgLevelCurr = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, 
                                            EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName
                                            FROM EUR_CRM_Pros_Image_Level__c
                                            WHERE EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()
                                            AND EUR_CRM_Criteria_Threshold__c IN: ctIds ORDER BY EUR_CRM_Weight__c];
        }
        List<EUR_CRM_Criteria_Answer__c> cAnswerListTempCurr = [SELECT Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, 
                                                                    EUR_CRM_Value__c,EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c, EUR_CRM_Base_Currency__c 
                                                                    FROM EUR_CRM_Criteria_Answer__c
                                                                    WHERE EUR_CRM_Criteria_Threshold__c IN: ctIds
                                                                    ORDER BY EUR_CRM_Weight__c desc, EUR_CRM_Base_Currency__c desc]; 
        
        for (EUR_CRM_Criteria_Answer__c ans: cAnswerListTempCurr){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMapCurr.containsKey(key))?cAnswerMapCurr.get(key):new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMapCurr.put(key,ansList);
        }                                           
        
        for (EUR_CRM_Pros_Image_Level__c p : updateListProsSegImgLevelCurr){
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
                cAnswerMapCurr.get(p.EUR_CRM_Criteria_Threshold__c),
                answer,
                thresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c),
                thresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName
            );
            
            p.EUR_CRM_Weight__c = answerWeight/100;
            updateListProsSegImgLevel.add(p);
        }                     
    }
    
    public void calculateText(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapText = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();
        List<EUR_CRM_Pros_Image_Level__c> updateListProsSegImgLevelText = null;
        
        ctList = [SELECT Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c FROM EUR_CRM_Criteria_Threshold__c
                    WHERE EUR_CRM_Criteria_Set__c =: cSetId  AND Recordtype.DeveloperName =:'EUR_CRM_Text_Input'];
        system.debug('ctListDevNameText' + ctList.size()); 
        Double answerWeight = 0;
        Map <Id,EUR_CRM_Criteria_Threshold__c >  thresholdWeightMap = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        
        for (EUR_CRM_Criteria_Threshold__c e: ctList){
            system.debug('eeeeee' + e.RecordType.DeveloperName);
            ctIds.add(e.Id);
            thresholdWeightMap.put(e.Id, e);
    
        }
        system.debug('prosSegIdMap' + prosSegIdMap);
        system.debug('prosSegIdMap2' + prosSegIdMap.keyset());
        
        updateListProsSegImgLevelText = new List<EUR_CRM_Pros_Image_Level__c>();
        
        if(ctIds.size()>0){
        updateListProsSegImgLevelText = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,
                                            EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName   FROM EUR_CRM_Pros_Image_Level__c
                                            WHERE EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()
                                            AND EUR_CRM_Criteria_Threshold__c IN: ctIds ORDER BY EUR_CRM_Weight__c];    
        }
                                       
        for (EUR_CRM_Pros_Image_Level__c p : updateListProsSegImgLevelText){
            EUR_CRM_Pros_Image_Level__c prosImg = new EUR_CRM_Pros_Image_Level__c();
            prosImg.EUR_CRM_Criteria_Threshold__c = p.EUR_CRM_Criteria_Threshold__c;
            prosImg.EUR_CRM_Pros_Segmentation__c = p.EUR_CRM_Pros_Segmentation__c;
            prosImg.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
            prosImg.id = p.id;

            if (thresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Text_Input')){               
                prosImg.EUR_CRM_Weight__c = 0;      
            }
            updateListProsSegImgLevel.add(prosImg);
        }
    }
    
    /********************
    Calculate Volume Potentials
    ********************/
    public void calculateBooleanVol(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        List<EUR_CRM_Pros_Volume_Potential__c> updateProsVolPotentialListBoolean = null;
        List<EUR_CRM_Pros_Volume_Potential__c> updateProsVolPotentialListBoolean2 = null;
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapBooleanVol = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();

        Map <Id,EUR_CRM_Criteria_Threshold__c >  volThresholdWeightMap = new Map<Id,EUR_CRM_Criteria_Threshold__c>();

        for (EUR_CRM_Criteria_Threshold__c e: [SELECT Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c FROM EUR_CRM_Criteria_Threshold__c
                                                WHERE EUR_CRM_Criteria_Set__c =: cSetId  AND Recordtype.DeveloperName =:'EUR_CRM_Boolean']){
            //system.debug('eeeeee' + e.RecordType.DeveloperName);
            ctIds.add(e.Id);
            volThresholdWeightMap.put(e.Id, e);
        }
        system.debug('prosSegIdMap' + prosSegIdMap);
        system.debug('prosSegIdMap2' + prosSegIdMap.keyset());
        
        updateProsVolPotentialListBoolean = new List<EUR_CRM_Pros_Volume_Potential__c>();
        
        if(ctIds.size()>0){
        updateProsVolPotentialListBoolean = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, 
                                                EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName   
                                                FROM EUR_CRM_Pros_Volume_Potential__c
                                                WHERE EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()
                                                AND EUR_CRM_Criteria_Threshold__c IN: ctIds
                                                ORDER BY EUR_CRM_Weight__c];
        }
        List<EUR_CRM_Criteria_Answer__c> cAnswerListTempBool = [SELECT Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, 
                                                                    EUR_CRM_Value__c,EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c 
                                                                    FROM EUR_CRM_Criteria_Answer__c
                                                                    WHERE EUR_CRM_Criteria_Threshold__c IN: ctIds
                                                                    ORDER BY EUR_CRM_Base_Integer__c desc ]; 
        
        for (EUR_CRM_Criteria_Answer__c ans: cAnswerListTempBool){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMapBooleanVol.containsKey(key))?cAnswerMapBooleanVol.get(key):new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMapBooleanVol.put(key,ansList);
        }
        
        Double answerWeight = 0;
        for (EUR_CRM_Pros_Volume_Potential__c p : updateProsVolPotentialListBoolean){   
            EUR_CRM_Pros_Volume_Potential__c pv = new EUR_CRM_Pros_Volume_Potential__c();
            pv.EUR_CRM_Criteria_Threshold__c = p.EUR_CRM_Criteria_Threshold__c;
            pv.EUR_CRM_Pros_Segmentation__c = p.EUR_CRM_Pros_Segmentation__c;
            pv.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
            pv.id = p.id;
            
            for (EUR_CRM_Criteria_Answer__c ca : cAnswerMapBooleanVol.get(p.EUR_CRM_Criteria_Threshold__c)){    
                ca.EUR_CRM_Value__c = (ca.EUR_CRM_Value__c!=null)?ca.EUR_CRM_Value__c:'';
                if (volThresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Boolean')){
                    if (ca.EUR_CRM_Value__c.equalsIgnorecase(p.EUR_CRM_Answer__c)){
                        answerWeight = ca.EUR_CRM_Weight__c * volThresholdWeightMap.get(p.EUR_CRM_Criteria_Threshold__c).EUR_CRM_Weight__c;
                    }   
                }                       
            }
            //system.debug('#####answerWeight' + answerWeight/100);
            pv.EUR_CRM_Weight__c = answerWeight/100;
            updateListProsSegVolLevel.add(pv);
        }
    }
    
    public void calculateIntegerVol(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        List<EUR_CRM_Pros_Volume_Potential__c> updateProsVolPotentialListInt = null;
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapIntVol = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();

        Double answerWeight = 0;
        Map <Id,EUR_CRM_Criteria_Threshold__c >  volThresholdWeightMapInt = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        
        for (EUR_CRM_Criteria_Threshold__c e: [SELECT Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c FROM EUR_CRM_Criteria_Threshold__c
                                                    WHERE EUR_CRM_Criteria_Set__c =: cSetId  AND Recordtype.DeveloperName =:'EUR_CRM_Integer_Input']){
            ctIds.add(e.Id);
            volThresholdWeightMapInt.put(e.Id, e);
        }
        system.debug('prosSegIdMap' + prosSegIdMap);
        system.debug('prosSegIdMap2' + prosSegIdMap.keyset());
        
        updateProsVolPotentialListInt = new List<EUR_CRM_Pros_Volume_Potential__c>();
        
        if(ctIds.size()>0){
        updateProsVolPotentialListInt = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, 
                                            EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName
                                            FROM EUR_CRM_Pros_Volume_Potential__c
                                            WHERE EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()
                                            AND EUR_CRM_Criteria_Threshold__c IN: ctIds // AND EUR_CRM_Is_Mass_Update__c = true 
                                            ORDER BY EUR_CRM_Weight__c];
        }
        system.debug('updateProsVolPotentialListInt' + updateProsVolPotentialListInt.size());   
        
        List<EUR_CRM_Criteria_Answer__c> cAnswerListTempInt = [SELECT Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, 
                                                                    EUR_CRM_Value__c,EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c 
                                                                    FROM EUR_CRM_Criteria_Answer__c
                                                                    WHERE EUR_CRM_Criteria_Threshold__c IN: ctIds
                                                                    ORDER BY EUR_CRM_Weight__c desc, EUR_CRM_Base_Integer__c desc ]; 
        
        for (EUR_CRM_Criteria_Answer__c ans: cAnswerListTempInt){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMapIntVol.containsKey(key))?cAnswerMapIntVol.get(key):new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMapIntVol.put(key,ansList);
        }                   
        
        for (EUR_CRM_Pros_Volume_Potential__c p : updateProsVolPotentialListInt){
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
                cAnswerMapIntVol.get(p.EUR_CRM_Criteria_Threshold__c),
                answer,
                volThresholdWeightMapInt.get(p.EUR_CRM_Criteria_Threshold__c),
                volThresholdWeightMapInt.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName
            );          
              
            p.EUR_CRM_Weight__c = answerWeight/100;
            system.debug('#####answerWeight2' + p);
            updateListProsSegVolLevel.add(p);
        }                       
    }
    
    public void calculatePicklistVol(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        List<EUR_CRM_Pros_Volume_Potential__c> updateProsVolPotentialListPick = null;
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapIntVol = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();

        Double answerWeight = 0;
        Map <Id,EUR_CRM_Criteria_Threshold__c >  volThresholdWeightMapPick = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        
        for (EUR_CRM_Criteria_Threshold__c e: [SELECT Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c 
                                                    FROM EUR_CRM_Criteria_Threshold__c
                                                    WHERE EUR_CRM_Criteria_Set__c =: cSetId  AND Recordtype.DeveloperName =:'EUR_CRM_Picklist']){
            ctIds.add(e.Id);
            volThresholdWeightMapPick.put(e.Id, e);
        }
        
        system.debug('prosSegIdMap' + prosSegIdMap);
        system.debug('prosSegIdMap2' + prosSegIdMap.keyset());
        updateProsVolPotentialListPick = new List<EUR_CRM_Pros_Volume_Potential__c>();
        
        updateProsVolPotentialListPick = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, 
                                            EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName 
                                            FROM EUR_CRM_Pros_Volume_Potential__c
                                            WHERE EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()
                                            AND EUR_CRM_Criteria_Threshold__c IN: ctIds
                                            ORDER BY EUR_CRM_Weight__c];
        
        List<EUR_CRM_Criteria_Answer__c> cAnswerListTempPick = [SELECT Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, 
                                                                    EUR_CRM_Value__c,EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c 
                                                                    FROM EUR_CRM_Criteria_Answer__c
                                                                    WHERE EUR_CRM_Criteria_Threshold__c IN: ctIds
                                                                    ORDER BY EUR_CRM_Base_Integer__c desc];     
        
        for (EUR_CRM_Criteria_Answer__c ans: cAnswerListTempPick){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMapIntVol.containsKey(key))?cAnswerMapIntVol.get(key):new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMapIntVol.put(key,ansList);
        }               

        for (EUR_CRM_Pros_Volume_Potential__c p : updateProsVolPotentialListPick){
            EUR_CRM_Pros_Volume_Potential__c pv = new EUR_CRM_Pros_Volume_Potential__c();
            pv.EUR_CRM_Criteria_Threshold__c = p.EUR_CRM_Criteria_Threshold__c;
            pv.EUR_CRM_Pros_Segmentation__c = p.EUR_CRM_Pros_Segmentation__c;
            pv.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
            pv.id = p.id;
            
            for (EUR_CRM_Criteria_Answer__c ca : cAnswerMapIntVol.get(p.EUR_CRM_Criteria_Threshold__c)){                
                if (volThresholdWeightMapPick.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Picklist')){
                    ca.EUR_CRM_Value__c = (ca.EUR_CRM_Value__c!=null)?ca.EUR_CRM_Value__c:'';
                    if (ca.EUR_CRM_Value__c.equalsIgnorecase(p.EUR_CRM_Answer__c)){
                        answerWeight = ca.EUR_CRM_Weight__c * volThresholdWeightMapPick.get(p.EUR_CRM_Criteria_Threshold__c).EUR_CRM_Weight__c;
                    }                           
                }
            }
            pv.EUR_CRM_Weight__c = answerWeight/100;
            updateListProsSegVolLevel.add(pv);
        }      
    }
    
    public void calculateCurrencyVol(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        List<EUR_CRM_Pros_Volume_Potential__c> updateProsVolPotentialListCurr = null;
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapVolCurr = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();
 
        Double answerWeight = 0;
        Map <Id,EUR_CRM_Criteria_Threshold__c >  volThresholdWeightMapCurr = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        
        for (EUR_CRM_Criteria_Threshold__c e: [SELECT Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c 
                                                    FROM EUR_CRM_Criteria_Threshold__c
                                                    WHERE EUR_CRM_Criteria_Set__c =: cSetId  AND Recordtype.DeveloperName =:'EUR_CRM_Currency_Input']){
            ctIds.add(e.Id);
            volThresholdWeightMapCurr.put(e.Id, e);
        }
        system.debug('prosSegIdMap' + prosSegIdMap);
        system.debug('prosSegIdMap2' + prosSegIdMap.keyset());
        
        updateProsVolPotentialListCurr = new List<EUR_CRM_Pros_Volume_Potential__c>();
        updateProsVolPotentialListCurr = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,
                                            EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName FROM EUR_CRM_Pros_Volume_Potential__c
                                            WHERE EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()
                                            AND EUR_CRM_Criteria_Threshold__c IN: ctIds
                                            ORDER BY EUR_CRM_Weight__c ];
        
        List<EUR_CRM_Criteria_Answer__c> cAnswerListTempCurr = [SELECT Id, EUR_CRM_Weight__c, RecordtypeId, EUR_CRM_Criteria_Threshold__c, 
                                                                    EUR_CRM_Value__c,EUR_CRM_Condition__c, EUR_CRM_Base_Integer__c, EUR_CRM_Base_Currency__c 
                                                                    FROM EUR_CRM_Criteria_Answer__c
                                                                    WHERE EUR_CRM_Criteria_Threshold__c IN: ctIds
                                                                    ORDER BY EUR_CRM_Weight__c desc, EUR_CRM_Base_Currency__c desc]; 
                        
        for (EUR_CRM_Criteria_Answer__c ans: cAnswerListTempCurr){
            Id key = ans.EUR_CRM_Criteria_Threshold__c;
            List<EUR_CRM_Criteria_Answer__c> ansList = (cAnswerMapVolCurr.containsKey(key))?cAnswerMapVolCurr.get(key):new List<EUR_CRM_Criteria_Answer__c>();
            ansList.add(ans);
            cAnswerMapVolCurr.put(key,ansList);
        }               
                                                    
        for (EUR_CRM_Pros_Volume_Potential__c p : updateProsVolPotentialListCurr){
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
                cAnswerMapVolCurr.get(p.EUR_CRM_Criteria_Threshold__c),
                answer,
                volThresholdWeightMapCurr.get(p.EUR_CRM_Criteria_Threshold__c),
                volThresholdWeightMapCurr.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName
            );            
            
            p.EUR_CRM_Weight__c = answerWeight/100;
            updateListProsSegVolLevel.add(p);
        }                     
    }
   
    public void calculateTextVol(){
        Set<Id> ctIds = new Set<Id>();
        List<EUR_CRM_Criteria_Threshold__c> ctList = new List<EUR_CRM_Criteria_Threshold__c>();
        List<EUR_CRM_Criteria_Answer__c> cAnswerList = new List<EUR_CRM_Criteria_Answer__c>();
        List<EUR_CRM_Pros_Volume_Potential__c> updateProsVolPotentialListText = null;
        Map<Id,List<EUR_CRM_Criteria_Answer__c>> cAnswerMapVolText = new Map<Id,List<EUR_CRM_Criteria_Answer__c>>();
        
        Double answerWeight = 0;
        Map <Id,EUR_CRM_Criteria_Threshold__c >  volThresholdWeightMapText = new Map<Id,EUR_CRM_Criteria_Threshold__c>();
        
        for (EUR_CRM_Criteria_Threshold__c e: [SELECT Id, EUR_CRM_Criteria_Set__c, RecordType.DeveloperName, EUR_CRM_Weight__c 
                                                    FROM EUR_CRM_Criteria_Threshold__c
                                                    WHERE EUR_CRM_Criteria_Set__c =: cSetId  AND Recordtype.DeveloperName =:'EUR_CRM_Text_Input']){
            ctIds.add(e.Id);
            volThresholdWeightMapText.put(e.Id, e);
        }
        
        system.debug('prosSegIdMap' + prosSegIdMap);
        system.debug('prosSegIdMap2' + prosSegIdMap.keyset());
        
        updateProsVolPotentialListText = new List<EUR_CRM_Pros_Volume_Potential__c>();
        updateProsVolPotentialListText = [SELECT Id, EUR_CRM_Answer__c, EUR_CRM_Pros_Segmentation__c, EUR_CRM_Criteria_Threshold__c, EUR_CRM_Criteria_Threshold__r.EUR_CRM_Weight__c,
                                            EUR_CRM_Criteria_Threshold__r.Recordtype.DeveloperName FROM EUR_CRM_Pros_Volume_Potential__c
                                            WHERE EUR_CRM_Pros_Segmentation__c IN: prosSegIdMap.keyset()
                                            AND EUR_CRM_Criteria_Threshold__c IN: ctIds
                                            ORDER BY EUR_CRM_Weight__c];                                        
            
        for (EUR_CRM_Pros_Volume_Potential__c p : updateProsVolPotentialListText){
            EUR_CRM_Pros_Volume_Potential__c pv = new EUR_CRM_Pros_Volume_Potential__c();
            pv.EUR_CRM_Criteria_Threshold__c = p.EUR_CRM_Criteria_Threshold__c;
            pv.EUR_CRM_Pros_Segmentation__c = p.EUR_CRM_Pros_Segmentation__c;
            pv.EUR_CRM_Answer__c = p.EUR_CRM_Answer__c;
            pv.id = p.id;

            if (volThresholdWeightMapText.get(p.EUR_CRM_Criteria_Threshold__c).RecordType.DeveloperName.contains('EUR_CRM_Text_Input')){
                pv.EUR_CRM_Weight__c = 0;
            }
            updateListProsSegVolLevel.add(pv);
        }
    }
    
    /**
    *   function: calculateAnswerWeight
    *   Dynamically calculates answer weight of a given answer
    *   REMARKS: THIS CODE ASSUMES THAT THE WEIGHT AND BASE NUMBER OF THE ANSWERS ARE SORTED DESC
    *   input: List of criteria answers to be weighted
    *          Criteria Threshold (Used to determine weight)
    *          String the answer type (Boolean/Text/Currency/Integer)
    *   return: calculated weight of the answer
    */
    public Double calculateAnswerWeight(List<EUR_CRM_Criteria_Answer__c> criteriaAnswer, Double answer, EUR_CRM_Criteria_Threshold__c criteriaThreshold, String inputRecordType) {
        
        // Groups criteria answers to different list
        List<EUR_CRM_Criteria_Answer__c> lessThanCriteriaAnswerList = new List<sObject>(criteriaAnswer.size());
        
        // Determine the field used to store each base number based on the recordtype
        String fieldName = inputRecordType.contains('EUR_CRM_Currency_Input') ? 'EUR_CRM_Base_Currency__c' : 'EUR_CRM_Base_Integer__c';
        
        // Determine the weight of answer by looping each criteria answer and checking if it meets the condition
        for(EUR_CRM_Criteria_Answer__c ca: criteriaAnswer) {
            Boolean isCriteriaMet = false;
            
            if(criteriaThreshold.RecordType.DeveloperName.contains(inputRecordType)) {
                if(ca.EUR_CRM_Condition__c != null) {
                    String condition = ca.EUR_CRM_Condition__c;
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
                System.debug(criteriaThreshold);
                return ca.EUR_CRM_Weight__c * criteriaThreshold.EUR_CRM_Weight__c;
            }
        }
        
        // Checks if there are conditions involving < or <=
        if(lessThanCriteriaAnswerList.size() != 0 && lessThanCriteriaAnswerList[0] != null) {
            for(EUR_CRM_Criteria_Answer__c ca: lessThanCriteriaAnswerList) {
                if(ca != null && ca.EUR_CRM_Condition__c != null){
                    Boolean isCriteriaMet = false;
                    String condition = ca.EUR_CRM_Condition__c;
                    condition = condition.subString(condition.indexOf('(')+1, condition.indexOf(')')).trim();
                    if (condition.equalsIgnorecase('<=')) {
                        isCriteriaMet = (answer <= (Double) ca.get(fieldName)) ? true : false;
                    } else {
                        isCriteriaMet = (answer < (Double) ca.get(fieldName)) ? true : false;
                    }
                    
                    if(isCriteriaMet) {
                        System.debug(ca);
                        System.debug(criteriaThreshold);
                        return ca.EUR_CRM_Weight__c * criteriaThreshold.EUR_CRM_Weight__c;
                    }
                }
            }
        }
        
        System.debug('ERROR!!!!! ' + criteriaAnswer);
        return 0;
    }
}