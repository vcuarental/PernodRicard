/*********************************************************************************
 * Name: ASI_CRM_TW_CriteriaController
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 05/03/2015       Introv: Twinkle         Cloned from ASI_CRM_CriteriaController
*********************************************************************************/

public without sharing class ASI_CRM_TW_CriteriaController {

    private final Integer IMAGE_LEVEL = 1;
    private final Integer VOLUME_POTENTIAL = 2;
    private Integer sheetType{set; get;}
    private ApexPages.StandardController standardController;
    private ASI_CRM_TW_CriteriaManager mgr {get;set;}
    private Double total;
    
    private ASI_CRM_Pros_Segmentation__c prosSegmentation;
    private ASI_CRM_Criteria_Set__c criteriaSetInfo;
    private ASI_CRM_Group_Outlet_Type__c groupOutletTypeInfo;
    private Map<Id, ASI_CRM_Criteria_Threshold__c> criteriaThresholds;
    private List<ASI_CRM_Criteria_Threshold__c> criteriaThresholdsList{get;set;}
    private List<ASI_CRM_Criteria_Answer__c> answers;
    private Map<Id, List<ASI_CRM_Criteria_Answer__c>> criteriaAnswers;
    private Map<Id, ASI_CRM_Pros_Image_Level__c> imageLevelMap{get;set;}{imageLevelMap = new Map<Id, ASI_CRM_Pros_Image_Level__c>();}
    private Map<Id, ASI_CRM_Pros_Volume_Potential__c> volumePotentialMap{get;set;}{volumePotentialMap = new Map<Id, ASI_CRM_Pros_Volume_Potential__c>();}
    //12/11/2014 - Reference junction objs Image Level and Volume Potential Thresholds
    private List<ASI_CRM_Image_Level_Threshold__c> imageLevelThresholds;
    private List<ASI_CRM_Volume_Potential_Threshold__c> volumePotentialThresholds;
    
    private List<ASI_CRM_Pros_Image_Level__c>newImageLevels;
    private List<ASI_CRM_Pros_Volume_Potential__c>newVolumePotentials;
    
    public Map<Id, String> answerSheet{get;set;}
    public Boolean criteriaSheetReadyFlag{get;set;}{criteriaSheetReadyFlag=false;}
    
    public ASI_CRM_AccountsAdditionalField__c cust {get;set;}
    public boolean boolNotShowPage {get;set;}
    public id AccId {get;set;}
    Map<Id, ASI_CRM_Image_Level_Threshold__c> mapImageLevelThresholds {get;set;}
    
    public ASI_CRM_TW_CriteriaController(ApexPages.StandardController standardController){
        this.standardController = standardController;
        this.sheetType = Integer.valueOf(ApexPages.currentPage().getParameters().get('type'));
        System.debug('Type' + sheetType);
        
        mgr = new ASI_CRM_TW_CriteriaManager();
        imageLevelMap = new Map<Id, ASI_CRM_Pros_Image_Level__c>();
        volumePotentialMap = new Map<Id, ASI_CRM_Pros_Volume_Potential__c>();        
        
        initController();
    }
    
    private void initController(){
        //TODO APPLY RECORD TYPE
        this.total = 0;
        criteriaSheetReadyFlag = initProsSegmentationDetails();
        
        if(this.prosSegmentation.ASI_CRM_SG_Customer__c != NULL)
            cust = [SELECT id, ASI_CRM_SG_Image_Level__c, ASI_CRM_Approval_Status__c FROM ASI_CRM_AccountsAdditionalField__c WHERE id=:this.prosSegmentation.ASI_CRM_SG_Customer__c];
        else
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Record corrupt. Customer is missing in Pros Segmentation.'));
            
        if(cust != NULL && cust.ASI_CRM_Approval_Status__c == 'Pending for Approval'){
            boolNotShowPage = TRUE;
        }
        
        if(criteriaSheetReadyFlag){
            getCriteriaThresholds();
            getAnswers();
            getCriteriaAnswers();
            returnAnswerSheet();
            
            if (sheetType == IMAGE_LEVEL){
                returnImageLevelMap();
            }
            /*else if (sheetType == VOLUME_POTENTIAL){
                returnVolumePotentialMap();
            }*/
            
            this.newImageLevels = new List<ASI_CRM_Pros_Image_Level__c>();
            this.newVolumePotentials = new List<ASI_CRM_Pros_Volume_Potential__c>();
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Pros Segmentation is not yet ready for criteria definition, missing group outlet type'));
        }
    }
    
    private Boolean initProsSegmentationDetails(){
        Boolean prosSegmentationFlag = false;
        
        this.prosSegmentation = null;
        System.debug('Flag-ID:' + this.standardController.getId()); 
        if (this.standardController.getId() != null){
            this.prosSegmentation = [SELECT Id, 
                                ASI_CRM_SG_Customer__c, ASI_CRM_SG_Customer__r.Id, 
                                ASI_CRM_SG_Account__c, ASI_CRM_SG_Account__r.Id,
                                ASI_CRM_SG_Group_Outlet_Type__c, ASI_CRM_SG_Outlet_Type__c,
                                ASI_CRM_SG_Image_Level__c, ASI_CRM_SG_Volume_Potential__c,
                                ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c,
                                ASI_CRM_SG_Image_Level_Id__c
                                FROM ASI_CRM_Pros_Segmentation__c
                                WHERE Id =: this.standardController.getId()
                                AND RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_CRM_Pros_Segmentation__cASI_CRM_TW_Pros_Segmentation') LIMIT 1
                                ];
            AccId = this.prosSegmentation.ASI_CRM_SG_Account__r.Id;            
            System.debug('prosSegmentation:'+prosSegmentation); 
        }
        this.groupOutletTypeInfo = null;
        if (prosSegmentation != null && prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c!=null){
            //Baltics - Modified query for country specific
            groupOutletTypeInfo = [SELECT Id, ASI_CRM_SG_Group_Outlet_Name__c, 
                                    ASI_CRM_SG_Image_Criteria_Set__r.Id, ASI_CRM_SG_Volume_Criteria_Set__r.Id
                                    FROM ASI_CRM_Group_Outlet_Type__c
                                    WHERE ASI_CRM_SG_Group_Outlet_Name__c =: prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c 
                                    AND RecordTypeId =: Global_RecordTypeCache.getRTId('ASI_CRM_Group_Outlet_Type__cASI_CRM_TW_Group_Outlet_Type') LIMIT 1];
                                    
            System.debug('groupOutletTypeInfo:'+groupOutletTypeInfo);
        }
        criteriaSetInfo = null;
        if(groupOutletTypeInfo != null){
            List<ASI_CRM_Criteria_Set__c> tempCriteriaSet = new List<ASI_CRM_Criteria_Set__c>();
            if (this.sheetType == IMAGE_LEVEL){
            tempCriteriaSet = [SELECT Id, ASI_CRM_SG_Name__c
                                FROM ASI_CRM_Criteria_Set__c WHERE Id =: groupOutletTypeInfo.ASI_CRM_SG_Image_Criteria_Set__r.Id LIMIT 1];
            }
            else if (this.sheetType == VOLUME_POTENTIAL){
            tempCriteriaSet = [SELECT Id, ASI_CRM_SG_Name__c
                                FROM ASI_CRM_Criteria_Set__c WHERE Id =: groupOutletTypeInfo.ASI_CRM_SG_Volume_Criteria_Set__r.Id LIMIT 1];
            }
                                
            System.debug('tempCriteriaSet:' + tempCriteriaSet);
            if (tempCriteriaSet.size()> 0){
                criteriaSetInfo = tempCriteriaSet[0];
            }            
            System.debug('getCriteriaSetInfo:'+criteriaSetInfo);
            
            prosSegmentationFlag = true;
        }
        
        return prosSegmentationFlag;
    }

    //SETTER
    public void setCriteriaSetInfo(ASI_CRM_Criteria_Set__c criteriaSetInfo)
    {
        this.criteriaSetInfo = criteriaSetInfo;
    }
    public void setCriteriaThreshold(Map<Id, ASI_CRM_Criteria_Threshold__c> criteriaThresholds)
    {
        this.criteriaThresholds = criteriaThresholds;
    }
    public void setCriteriaAnswers(Map<Id, List<ASI_CRM_Criteria_Answer__c>> criteriaAnswers)
    {
        this.criteriaAnswers = criteriaAnswers;
    }
    public void setAnswers(List<ASI_CRM_Criteria_Answer__c> answers)
    {
        this.answers = answers;
    }
    public void setImageLevelThresholds (List<ASI_CRM_Image_Level_Threshold__c> imageLevelThresholds){
        this.imageLevelThresholds = imageLevelThresholds;
    }
    public void setVolumePotentialThresholds (List<ASI_CRM_Volume_Potential_Threshold__c> volumePotentialThresholds){
        this.volumePotentialThresholds = volumePotentialThresholds;
    }
       
    public Map<Id, ASI_CRM_Criteria_Threshold__c> getCriteriaThresholds()
    {   
        System.debug('Flag 2 getCriteriaSetInfo:'+criteriaSetInfo);
        criteriaThresholds = new  Map<Id, ASI_CRM_Criteria_Threshold__c>();
        if (criteriaSetInfo !=null)
        {   
                criteriaThresholdsList = [SELECT Id, RecordTypeId,
                                    ASI_CRM_SG_Question__c, ASI_CRM_SG_Weight__c,
                                    ASI_CRM_SG_Criteria_Order__c
                                    FROM ASI_CRM_Criteria_Threshold__c 
                                    WHERE ASI_CRM_SG_Criteria_Set__r.Id=:criteriaSetInfo.Id
                                    ORDER BY ASI_CRM_SG_Sequence__c, ASI_CRM_SG_Criteria_Order__c, CreatedDate];
                                    
            for (ASI_CRM_Criteria_Threshold__c ct: criteriaThresholdsList) {
                criteriaThresholds.put(ct.Id, ct);
            }
        }
        System.debug('getCriteriaThresholds:'+criteriaThresholds);
        return criteriaThresholds;
    }
    public List<ASI_CRM_Criteria_Answer__c> getAnswers()
    {
        System.debug('Flag 2 getCriteriaThresholds:'+criteriaThresholds);
        answers = new List<ASI_CRM_Criteria_Answer__c>();
        if (criteriaThresholds.size()>0)
        {
            answers = [SELECT Id, RecordTypeId, Recordtype.DeveloperName,
                        ASI_CRM_SG_Value__c, 
                        ASI_CRM_SG_Base_Currency__c, ASI_CRM_SG_Base_Integer__c,
                        ASI_CRM_SG_Condition__c, ASI_CRM_SG_Criteria_Threshold__r.Id,
                        ASI_CRM_SG_Label__c, ASI_CRM_SG_Weight__c
                        FROM ASI_CRM_Criteria_Answer__c 
                        WHERE ASI_CRM_SG_Criteria_Threshold__r.Id in: criteriaThresholds.keySet() 
                        ORDER BY ASI_CRM_SG_Weight__c ASC];
         }
        System.debug('getAnswers:'+answers);
          System.debug('getAnswersSize:'+answers.size());
        return answers;
    }
    
    public Map<Id, List<ASI_CRM_Criteria_Answer__c>> getCriteriaAnswers()
    {
        System.debug('Flag 2 getAnswers:'+answers);
        criteriaAnswers = new Map<Id, List<ASI_CRM_Criteria_Answer__c>>();
        if (answers.size()>0)
        {
            for (ASI_CRM_Criteria_Answer__c ans: answers){
                List<ASI_CRM_Criteria_Answer__c> criteriaAnsList = new List<ASI_CRM_Criteria_Answer__c>();
                if (criteriaAnswers.containsKey(ans.ASI_CRM_SG_Criteria_Threshold__r.Id)){
                    criteriaAnsList = criteriaAnswers.get(ans.ASI_CRM_SG_Criteria_Threshold__r.Id);
                }
                criteriaAnsList.add(ans);
                criteriaAnswers.put(ans.ASI_CRM_SG_Criteria_Threshold__r.Id, criteriaAnsList);
            }
        }
        System.debug('getCriteriaAnswers:'+criteriaAnswers);
        return criteriaAnswers;
    }
       
    public Map<Id,  ASI_CRM_Pros_Image_Level__c> returnImageLevelMap(){
        if (this.standardController.getId() != null)
        {
            List<ASI_CRM_Pros_Image_Level__c> prosImageLevels = [SELECT Id, ASI_CRM_SG_Criteria_Threshold__r.Id, 
                            ASI_CRM_SG_Weight__c, ASI_CRM_SG_Answer__c
                            FROM ASI_CRM_Pros_Image_Level__c
                            WHERE ASI_CRM_SG_Pros_Segmentation__r.Id =: this.standardController.getId()];
                            
            for(ASI_CRM_Pros_Image_Level__c prosImageLevel: prosImageLevels)
            {
                imageLevelMap.put(prosImageLevel.ASI_CRM_SG_Criteria_Threshold__r.Id, prosImageLevel);
                answerSheet.put(prosImageLevel.ASI_CRM_SG_Criteria_Threshold__r.Id, (prosImageLevel.ASI_CRM_SG_Answer__c==null)?'':prosImageLevel.ASI_CRM_SG_Answer__c);
            }             
        }
        system.debug('!!!' + imageLevelMap.size());
        return imageLevelMap;
    }
       
    /*public Map<Id,  ASI_CRM_Pros_Volume_Potential__c> returnVolumePotentialMap()
    {
        if (this.standardController.getId() != null)
        {
            List<ASI_CRM_Pros_Volume_Potential__c> prosVolumePotentials = [SELECT Id, ASI_CRM_SG_Criteria_Threshold__r.Id, 
                            ASI_CRM_SG_Weight__c, ASI_CRM_SG_Answer__c
                            FROM ASI_CRM_Pros_Volume_Potential__c
                            WHERE ASI_CRM_SG_Pros_Segmentation__r.Id =: this.standardController.getId()];
                            
            for(ASI_CRM_Pros_Volume_Potential__c prosVolumePotential: prosVolumePotentials)
            {
                volumePotentialMap.put(prosVolumePotential.ASI_CRM_SG_Criteria_Threshold__r.Id, prosVolumePotential);
                answerSheet.put(prosVolumePotential.ASI_CRM_SG_Criteria_Threshold__r.Id, (prosVolumePotential.ASI_CRM_SG_Answer__c==null)?'':prosVolumePotential.ASI_CRM_SG_Answer__c);
            }    
        }
        System.debug('volumePotentialMap: ' + volumePotentialMap);
        return volumePotentialMap;
    }*/
    
    public Map<Id, String>  returnAnswerSheet(){
        answerSheet = new Map<Id, String>();
        for (Id key : criteriaAnswers.keySet()){
            if (!answerSheet.containsKey(key)){
                answerSheet.put(key, '');
            }       
        }
        return answerSheet;
    }
    
    public List<ASI_CRM_Image_Level_Threshold__c> getImageLevelThresholds(Id groupOutletType){
        imageLevelThresholds = new List<ASI_CRM_Image_Level_Threshold__c>();
        mapImageLevelThresholds = new Map<Id, ASI_CRM_Image_Level_Threshold__c>();
        imageLevelThresholds = [SELECT ASI_CRM_SG_Image_Level_Name__c, ASI_CRM_SG_Min_Weight__c, ASI_CRM_SG_Image_Level__c, ASI_CRM_SG_Image_Level__r.ASI_CRM_Outlet_Image__c
                                FROM ASI_CRM_Image_Level_Threshold__c
                                WHERE ASI_CRM_SG_Group_Outlet_Type__c =: groupOutletType
                                ORDER BY ASI_CRM_SG_Min_Weight__c];
        for(ASI_CRM_Image_Level_Threshold__c itm : imageLevelThresholds){
            mapImageLevelThresholds.put(itm.id, itm);
        }                        
        System.debug('ImageLevelThreshold query - groupOutlet Type:' + groupOutletType);
        system.debug('@@@@@imageLevelThresholds' + imageLevelThresholds);
        return imageLevelThresholds;
    }
    
    public List<ASI_CRM_Volume_Potential_Threshold__c> getVolumePotentialThresholds (String groupOutletType){
        volumePotentialThresholds = new List<ASI_CRM_Volume_Potential_Threshold__c>();
        
        volumePotentialThresholds = [SELECT ASI_CRM_SG_Volume_Potential_Name__c, ASI_CRM_SG_Min_Weight__c 
                                FROM ASI_CRM_Volume_Potential_Threshold__c
                                WHERE ASI_CRM_SG_Group_Outlet_Type__c =: groupOutletType
                                ORDER BY ASI_CRM_SG_Min_Weight__c];
        
        return volumePotentialThresholds;
    }
   
    public Component.Apex.OutputPanel getCustomForm()
    {
        Component.Apex.OutputPanel customForm  = new Component.Apex.OutputPanel();
        if(criteriaSheetReadyFlag){
            customForm.layout = 'block';
            customForm.styleClass='requiredInput';
            
            if(criteriaAnswers.size()>0){
                System.debug('Flag - Answer sheet: ' + answerSheet);
                
                for (ASI_CRM_Criteria_Threshold__c ct : criteriaThresholdsList){
                    Id key = ct.Id;
                    String target = '{!answerSheet["'+key+'"]}';
                    String initValue = '';
                    
                    if(!answerSheet.containsKey(key) || (answerSheet.containsKey(key) && answerSheet.get(key)==null))
                            answerSheet.put(key, '');
                         
                    if(answerSheet.containsKey(key))
                            initValue = answerSheet.get(key);
                    system.debug('Init value:::' + initValue); 
                    
                    system.debug('Customer ID:::' + this.prosSegmentation.ASI_CRM_SG_Customer__r.Id);
                    system.debug('Criteria Threshold:::' + criteriaThresholds.get(key));
                    system.debug('Criteria Ans:::' + criteriaAnswers.get(key));
                    system.debug('Target:::' + target);
                    system.debug('Init value:::' + initValue);
                                              
                    Component.Apex.PageBlockSection subPanel = mgr.newClassInstance(criteriaThresholds.get(key).RecordTypeId).getCriteriaComponent(this.prosSegmentation.ASI_CRM_SG_Customer__r.Id, criteriaThresholds.get(key), criteriaAnswers.get(key), target, initValue);
                    customForm.childComponents.add(subPanel);
                }
            }
        }
        return customForm;
    }
    
    private boolean validateSheet(){
        Boolean isValid = true;
        for (String key: answerSheet.keySet()){
            String answer = answerSheet.get(key);
            System.debug('Flag - Validate Criteria:' + key +'|'+criteriaThresholds.get(key));
            if (criteriaThresholds.containsKey(key) && mgr.newClassInstance(criteriaThresholds.get(key).RecordTypeId).isRequired() && 
                (answer==null || answer=='' || (answer!=null && String.valueOf(answer).length()==0)))
                {
                this.addRequiredMessage();
                isValid = false;
                break;
            }
        }  
        
        return isValid; 
    }
    
    public PageReference saveCriteriaSheet(){
        PageReference pageRef = null;
        Database.Deleteresult[] deleteResults;
        Database.SaveResult[] insertResults;
        Database.SaveResult upsertResults;
        System.Savepoint pSavepoint = Database.setSavepoint();
        Boolean isSaved = true;
        
        System.debug('SAVING...' + answerSheet);
        
        if (validateSheet()){
            try{               
                for (String key: answerSheet.keySet()){
                    if (sheetType == IMAGE_LEVEL && criteriaThresholds.containsKey(key)){
                        ASI_CRM_Pros_Image_Level__c accountCriteria = saveImageLevel(key);
                        System.debug('Flag - Save - Check Account Criteria:' + accountCriteria);
                        if (accountCriteria != null){
                            this.total += accountCriteria.ASI_CRM_SG_Weight__c;
                        }
                    }
                    else if (sheetType == VOLUME_POTENTIAL && criteriaThresholds.containsKey(key)){
                        ASI_CRM_Pros_Volume_Potential__c accountCriteria = saveVolumePotential(key);
                        if (accountCriteria != null){
                            this.total += accountCriteria.ASI_CRM_SG_Weight__c;
                        }
                    }
                }
                    
                if (sheetType == IMAGE_LEVEL){
                    System.debug('Upsert: ' + imageLevelMap.values());
                    System.debug('&&THISTOTALIMAGE' + this.total);
                    System.debug('newImageLevels' + this.newImageLevels);
                    insertResults = Database.insert(this.newImageLevels);
                    System.debug('Flag - IMAGE_LEVEL INSERT RESULT' + insertResults);
   
                    this.prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c = retrieveImageLevel(this.total, this.prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c);
                    this.prosSegmentation.ASI_CRM_SG_Is_Image_Level_Modified__c = false;
                    
                    upsertResults = Database.update(this.prosSegmentation);
                    System.debug('Flag - IMAGE_LEVEL PROS UPSERT RESULT' + upsertResults);                    
                    System.debug('Flag - IMAGE_LEVEL' + this.prosSegmentation +'--'+ this.newImageLevels); 
                }    
                /*else if (sheetType == VOLUME_POTENTIAL){
                    System.debug('Upsert: ' + volumePotentialMap.values());
                    Database.insert(this.newVolumePotentials);
                    system.debug('&&THISTOTAL' + this.total);
                    this.prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c = retrieveVolumePotential(this.total, this.prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c);
                    this.prosSegmentation.ASI_CRM_SG_Is_Volume_Potential_Modified__c = false;
                    Database.update(this.prosSegmentation);
                    
                    system.debug('***VOLUME_POTENTIAL' + this.prosSegmentation.ASI_CRM_SG_Volume_Potential__c);
                }*/
                System.debug('Pros Segmentation:' + this.prosSegmentation);             
                
                if (isSaved){
                    pageRef = new PageReference('/' + AccId);  
                    pageRef.setRedirect(true); 
                }
            
            }
            catch(Exception e){
                pageRef = null;
                Database.rollback(pSavepoint);      
                String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
                if(e.getTypeName() == 'DMLException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION) 
                {
                    String s = e.getDmlMessage(0);
                    strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strError));
                }
                else if(e.getTypeName()=='DMLException' && e.getDmlType(0) == System.Statuscode.REQUIRED_FIELD_MISSING)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Missing Required Field/s'));
                }
                else{       
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
                }
            }
        }       
        //Update Customer Outlet Image               
        id ImageLevelThresholdId = retrieveImageLevel(this.total, this.prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c);
        if(ImageLevelThresholdId != NULL && mapImageLevelThresholds.get(ImageLevelThresholdId) != NULL && cust != NULL){
            cust.ASI_TH_CRM_OutletImage__c = mapImageLevelThresholds.get(ImageLevelThresholdId).ASI_CRM_SG_Image_Level__r.ASI_CRM_Outlet_Image__c;
            update cust;
        }
        
        System.debug('PageRef on Save:' + pageRef);
        return pageRef;
    }
    
    private ASI_CRM_Pros_Image_Level__c saveImageLevel(String key){
       // ASI_CRM_SG_CriteriaManager mgr = new ASI_CRM_SG_CriteriaManager();
       system.debug('###KEY' + key);
        ASI_CRM_Pros_Image_Level__c accountCriteria = null;
        accountCriteria = new ASI_CRM_Pros_Image_Level__c();
        accountCriteria.RecordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Pros_Image_Level__cASI_CRM_TW_Pros_Image_Level');
        accountCriteria.ASI_CRM_SG_Criteria_Threshold__c = key;
        accountCriteria.ASI_CRM_SG_Answer__c = answerSheet.get(key);
        accountCriteria.ASI_CRM_SG_Pros_Segmentation__c = this.standardController.getId();       
        System.debug('Flag - On Save Criteria Threshold:' + criteriaThresholds.get(key).ASI_CRM_SG_Question__c + '|' + answerSheet.get(key) + '|' + criteriaAnswers.get(key));
        List<ASI_CRM_Criteria_Answer__c> ansList = criteriaAnswers.get(key);
        ansList.sort();
        System.debug('FLAG - Save Image Level - Check Answer Options:'+criteriaThresholds.get(key).RecordTypeId+'-'+ ansList + '-' +answerSheet.get(key));
        Double answerWeight = mgr.newClassInstance(
            criteriaThresholds.get(key).RecordTypeId).calculateCriteria((Double)criteriaThresholds.get(key).ASI_CRM_SG_Weight__c, 
            ansList, 
            answerSheet.get(key));
        
        accountCriteria.ASI_CRM_SG_Weight__c = answerWeight;
        this.newImageLevels.add(accountCriteria);
        
        return accountCriteria;
    }
    
    private ASI_CRM_Pros_Volume_Potential__c saveVolumePotential(String key){
        //ASI_CRM_SG_CriteriaManager mgr = new ASI_CRM_SG_CriteriaManager();
        ASI_CRM_Pros_Volume_Potential__c accountCriteria = null;
        //if (!volumePotentialMap.containsKey(key)){
            accountCriteria = new ASI_CRM_Pros_Volume_Potential__c();
            accountCriteria.ASI_CRM_SG_Criteria_Threshold__c = key;
            accountCriteria.ASI_CRM_SG_Answer__c = answerSheet.get(key);
            accountCriteria.ASI_CRM_SG_Pros_Segmentation__c = this.standardController.getId();
          //  accountCriteria.ASI_CRM_SG_Is_Mass_Update__c = true;
            volumePotentialMap.put(key, accountCriteria);
        //}else{
            //accountCriteria = volumePotentialMap.get(key);
            //accountCriteria.ASI_CRM_SG_Answer__c = answerSheet.get(key);
        //}
        //Get answer weight (Threshold weight* answer weight)
        List<ASI_CRM_Criteria_Answer__c> ansList = criteriaAnswers.get(key);
        ansList.sort();
        System.debug('FLAG - Save Vol Potential - Check Answer Options:'+criteriaThresholds.get(key).RecordTypeId+'-'+ ansList + '-' +answerSheet.get(key));
        Double answerWeight = mgr.newClassInstance(
            criteriaThresholds.get(key).RecordTypeId).calculateCriteria((Double)criteriaThresholds.get(key).ASI_CRM_SG_Weight__c, 
            ansList, 
            answerSheet.get(key));
        
        accountCriteria.ASI_CRM_SG_Weight__c = answerWeight;
        
        this.newVolumePotentials.add(accountCriteria);
        return accountCriteria;
    }
    
    private String retrieveImageLevel (Double score, Id groupOutletType){
        system.debug('@@@groupOutletTypeImg' + groupOutletType);
        List<ASI_CRM_Image_Level_Threshold__c>imageLevels = this.getImageLevelThresholds(groupOutletType);
        String imageName = '';
        
        system.debug('---imageLevels '+imageLevels);
        if(imageLevels != null){
            if (score > imageLevels[imageLevels.size()-1].ASI_CRM_SG_Min_Weight__c){
                imageName = imageLevels[imageLevels.size()-1].Id;
            }else{
                for (Integer i=0; i<imageLevels.size(); i++){
                    Double left = imageLevels[i].ASI_CRM_SG_Min_Weight__c;
                    Double right = imageLevels[i].ASI_CRM_SG_Min_Weight__c;
                    if (imageLevels.size()-1 != i)
                        right = imageLevels[i+1].ASI_CRM_SG_Min_Weight__c;
                
                    if(left == score || score<right) 
                    {
                        //System.debug('1 - '+n+':' + x +'('+s[x]+')'); break;
                        imageName = imageLevels[i].Id;
                        break;
                    }
                    else if (score>right)
                    {
                        continue;
                    }
                }
            }
        }
        system.debug('Image Name :::' + imagename);
        return imageName;
    }
    
    private String retrieveVolumePotential (Double score, String groupOutletType){
     system.debug('@@@groupOutletTypeVol' + groupOutletType);
      system.debug('@@@SCOREVol' + score);
    List<ASI_CRM_Volume_Potential_Threshold__c>volumePotentials = this.getVolumePotentialThresholds(groupOutletType);
    String volumeLevel = '';
    
    if(volumePotentials != null){
        if (score > volumePotentials[volumePotentials.size()-1].ASI_CRM_SG_Min_Weight__c){
            volumeLevel = volumePotentials[volumePotentials.size()-1].Id;
            
            system.debug('%%%volumeLevel '+ volumeLevel);
        }else{
            system.debug('%%%2nd');
            for (Integer i=0; i<volumePotentials.size(); i++){
                Double left = volumePotentials[i].ASI_CRM_SG_Min_Weight__c;
                Double right = volumePotentials[i].ASI_CRM_SG_Min_Weight__c;
                if (volumePotentials.size()-1 != i)
                    right = volumePotentials[i+1].ASI_CRM_SG_Min_Weight__c;
            
                if(left == score || score<right) {
                    volumeLevel = volumePotentials[i].Id;
                    
                    break;
                }
                else if (score>right){
                    continue;
                }
            }
        }
    }
        system.debug('Image Name :::' + volumeLevel);
        return volumeLevel;
        }
    
    public void addRequiredMessage(){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Required Field: Missing Value'));
    } 
}