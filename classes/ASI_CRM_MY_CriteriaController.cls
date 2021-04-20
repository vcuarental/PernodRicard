/*********************************************************************************
 * Name: ASI_CRM_CriteriaController
 * Description: Controller class for update image level in PROS
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * ??????????       ??????                  Created
 * 2016-03-11       Laputa: Vincent			[VL 1.0] Add record type check for group outlet type
 */


public without sharing class ASI_CRM_MY_CriteriaController {

    private final Integer IMAGE_LEVEL = 1;
    private final Integer VOLUME_POTENTIAL = 2;
    private Integer sheetType{set; get;}
    private ApexPages.StandardController standardController;
    private ASI_CRM_CriteriaManager mgr {get;set;}
    private Double total;
    
    private ASI_CRM_Pros_Segmentation__c prosSegmentation{get; private set;}
    private ASI_CRM_Criteria_Set__c criteriaSetInfo{get; private set;}
    private ASI_CRM_Group_Outlet_Type__c groupOutletTypeInfo{get; private set;}
    private Map<Id, ASI_CRM_Criteria_Threshold__c> criteriaThresholds{get; private set;}
    private List<ASI_CRM_Criteria_Threshold__c> criteriaThresholdsList{get;set;}
    private List<ASI_CRM_Criteria_Answer__c> answers{get; private set;}
    private Map<Id, List<ASI_CRM_Criteria_Answer__c>> criteriaAnswers{get; private set;}
    private Map<Id, ASI_CRM_Pros_Image_Level__c> imageLevelMap{get;set;}{imageLevelMap = new Map<Id, ASI_CRM_Pros_Image_Level__c>();}
    private Map<Id, ASI_CRM_Pros_Volume_Potential__c> volumePotentialMap{get;set;}{volumePotentialMap = new Map<Id, ASI_CRM_Pros_Volume_Potential__c>();}
    //12/11/2014 - Reference junction objs Image Level and Volume Potential Thresholds
    private List<ASI_CRM_Image_Level_Threshold__c> imageLevelThresholds{get; private set;}
    private List<ASI_CRM_Volume_Potential_Threshold__c> volumePotentialThresholds{get; private set;}
    
    private List<ASI_CRM_Pros_Image_Level__c>newImageLevels{get; private set;}
    private List<ASI_CRM_Pros_Volume_Potential__c>newVolumePotentials{get; private set;}
    
    public Map<Id, String> answerSheet{get;set;}
    //public String formTitle{set; get;}
    //public String formHeader{set; get;}
    //public String formFooter{set; get;}
    public Boolean criteriaSheetReadyFlag{get;set;}{criteriaSheetReadyFlag=false;}
    
    public ASI_CRM_MY_CriteriaController(ApexPages.StandardController standardController){
        this.standardController = standardController;
        this.sheetType = Integer.valueOf(ApexPages.currentPage().getParameters().get('type'));
        System.debug('Type' + sheetType);
        
        mgr = new ASI_CRM_CriteriaManager();

        //System.debug('Check Pros Segmentation:' + this.standardController.Id+'|'+this.standardController.ASI_CRM_SG_Affiliate__r.Id+'|'+this.standardController.ASI_CRM_SG_Group_Outlet_Type__c);
        imageLevelMap = new Map<Id, ASI_CRM_Pros_Image_Level__c>();
        volumePotentialMap = new Map<Id, ASI_CRM_Pros_Volume_Potential__c>();
        
        initController();
    }
    
    private void initController()
    {
        //TODO APPLY RECORD TYPE
        this.total = 0;
        criteriaSheetReadyFlag = initProsSegmentationDetails();
        
        if(criteriaSheetReadyFlag){
            getCriteriaThresholds();
            getAnswers();
            getCriteriaAnswers();
            returnAnswerSheet();
            
            if (sheetType == IMAGE_LEVEL){
                returnImageLevelMap();
            }
            else if (sheetType == VOLUME_POTENTIAL){
                returnVolumePotentialMap();
            }
            
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
                                ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c
                                FROM ASI_CRM_Pros_Segmentation__c
                                WHERE Id =: this.standardController.getId() LIMIT 1
                                ];
                                
            System.debug('prosSegmentation:'+prosSegmentation); 
        }
        //return prosSegmentation;
        this.groupOutletTypeInfo = null;
        if (prosSegmentation != null && prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c!=null){
            //Baltics - Modified query for country specific
            groupOutletTypeInfo = [SELECT Id, ASI_CRM_SG_Group_Outlet_Name__c, 
                                    ASI_CRM_SG_Image_Criteria_Set__r.Id, ASI_CRM_SG_Volume_Criteria_Set__r.Id
                                    FROM ASI_CRM_Group_Outlet_Type__c
                                    WHERE ASI_CRM_SG_Group_Outlet_Name__c =: prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c 
                                   /* [VL 1.0] BEGIN */
                                   AND recordtype.developerName = 'ASI_CRM_MY_Group_Outlet_Type'
                                   /* [VL 1.0] END */
                                   LIMIT 1];
                                    
                                    //WHERE ASI_CRM_SG_Affiliate__r.Id=:prosSegmentation.ASI_CRM_SG_Affiliate__r.Id
                                    //AND ASI_CRM_SG_Name__c=:prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c LIMIT 1];
                                    
            System.debug('groupOutletTypeInfo:'+groupOutletTypeInfo);
        }
        criteriaSetInfo = null;
        if(groupOutletTypeInfo != null){
            List<ASI_CRM_Criteria_Set__c> tempCriteriaSet = new List<ASI_CRM_Criteria_Set__c>();
            //TODO Change filter to Group Outlet Type and Affiliate ID
            //TODO RECORD TYPE, IMAGE LEVEL AND VOL POTENTIAL
            if (this.sheetType == IMAGE_LEVEL){
            tempCriteriaSet = [SELECT Id, ASI_CRM_SG_Name__c
                                //ASI_CRM_SG_Header_Message__c, ASI_CRM_SG_Footer_Message__c, ASI_CRM_SG_Title__c
                                FROM ASI_CRM_Criteria_Set__c WHERE Id =: groupOutletTypeInfo.ASI_CRM_SG_Image_Criteria_Set__r.Id LIMIT 1];
            }
            else if (this.sheetType == VOLUME_POTENTIAL){
            tempCriteriaSet = [SELECT Id, ASI_CRM_SG_Name__c
                                //ASI_CRM_SG_Header_Message__c, ASI_CRM_SG_Footer_Message__c, ASI_CRM_SG_Title__c
                                FROM ASI_CRM_Criteria_Set__c WHERE Id =: groupOutletTypeInfo.ASI_CRM_SG_Volume_Criteria_Set__r.Id LIMIT 1];
            }
                                
            System.debug('tempCriteriaSet:' + tempCriteriaSet);
            if (tempCriteriaSet.size()> 0){
                if(Test.isRunningTest()){
                	setCriteriaSetInfo(tempCriteriaSet[0]);    
                }
                else{
                    criteriaSetInfo = tempCriteriaSet[0];
                }
                
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
    /*public void setAnswerSheet(Map<Id, String> answerSheet){
        this.answerSheet = answerSheet;
    }*/
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
            /*criteriaThresholds = new Map<Id, ASI_CRM_SG_Criteria_Threshold__c>(
                                    [SELECT Id, RecordTypeId,
                                    ASI_CRM_SG_Question__c, ASI_CRM_SG_Weight__c
                                    FROM ASI_CRM_Criteria_Threshold__c 
                                    WHERE ASI_CRM_SG_Criteria_Set__r.Id=:criteriaSetInfo.Id]);*/    
                criteriaThresholdsList = [SELECT Id, RecordTypeId,
                                    ASI_CRM_SG_Question__c, ASI_CRM_SG_Weight__c,
                                    ASI_CRM_SG_Criteria_Order__c
                                    FROM ASI_CRM_Criteria_Threshold__c 
                                    WHERE ASI_CRM_SG_Criteria_Set__r.Id=:criteriaSetInfo.Id
                                    ORDER BY ASI_CRM_SG_Sequence__c, CreatedDate];
                                    
            for (ASI_CRM_Criteria_Threshold__c ct: criteriaThresholdsList) {
                criteriaThresholds.put(ct.Id, ct);
            }
            
            if(Test.isRunningTest()){
                setCriteriaThreshold(criteriaThresholds);
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
                        ORDER BY ASI_CRM_SG_Base_Integer__c desc, ASI_CRM_SG_Base_Currency__c desc, ASI_CRM_SG_Label__c];
         }
        System.debug('getAnswers:'+answers);
          System.debug('getAnswersSize:'+answers.size());
        if(Test.isRunningTest()){
            setAnswers(answers);
        }
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
        if(Test.isRunningTest()){
        	setCriteriaAnswers(criteriaAnswers);
        }
        return criteriaAnswers;
    }
       
    public Map<Id,  ASI_CRM_Pros_Image_Level__c> returnImageLevelMap(){
        //imageLevelMap = new Map<Id,  ASI_CRM_SG_Pros_Image_Level__c>();
        
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
            /*imageLevelMap = new Map<Id, ASI_CRM_SG_Pros_Image_Level__c>(
                            [SELECT Id, ASI_CRM_SG_Criteria_Threshold__r.Id, 
                            ASI_CRM_SG_Weight__c, ASI_CRM_SG_Answer__c
                            FROM ASI_CRM_Pros_Image_Level__c
                            WHERE ASI_CRM_SG_Pros_Segmentation__r.Id =: this.standardController.getId()]);*/
        }
        system.debug('!!!' + imageLevelMap.size());
        return imageLevelMap;
    }
       
    public Map<Id,  ASI_CRM_Pros_Volume_Potential__c> returnVolumePotentialMap()
    {
        //volumePotentialMap = new Map<Id,  ASI_CRM_SG_Pros_Volume_Potential__c>();
        
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
            /*volumePotentialMap = new Map<Id, ASI_CRM_SG_Pros_Volume_Potential__c>(
                            [SELECT Id, ASI_CRM_SG_Criteria_Threshold__r.Id, 
                            ASI_CRM_SG_Weight__c, ASI_CRM_SG_Answer__c
                            FROM ASI_CRM_Pros_Volume_Potential__c
                            WHERE ASI_CRM_SG_Pros_Segmentation__r.Id =: this.standardController.getId()]);*/
        }
        System.debug('volumePotentialMap: ' + volumePotentialMap);
        return volumePotentialMap;
    }
    
    public Map<Id, String>  returnAnswerSheet(){
        answerSheet = new Map<Id, String>();
        for (Id key : criteriaAnswers.keySet()){
            if (!answerSheet.containsKey(key)){
                answerSheet.put(key, '');
            }       
        }
        return answerSheet;
    }
    
    public List<ASI_CRM_Image_Level_Threshold__c> getImageLevelThresholds(String groupOutletType){
        imageLevelThresholds = new List<ASI_CRM_Image_Level_Threshold__c>();
        
        /*imageLevelThresholds = [SELECT ASI_CRM_SG_Name__c, ASI_CRM_SG_Min_Weight__c 
                                FROM ASI_CRM_Image_Level__c
                                WHERE ASI_CRM_SG_Group_Outlet_Type__c =: groupOutletType
                                ORDER BY ASI_CRM_SG_Min_Weight__c];*/
                                
        imageLevelThresholds = [SELECT ASI_CRM_SG_Image_Level_Name__c, ASI_CRM_SG_Min_Weight__c, ASI_CRM_SG_Image_Level__r.Id
                                FROM ASI_CRM_Image_Level_Threshold__c
                                WHERE ASI_CRM_SG_Group_Outlet_Type__c =: groupOutletType
                                ORDER BY ASI_CRM_SG_Min_Weight__c];
        System.debug('ImageLevelThreshold query - groupOutlet Type:' + groupOutletType);
        system.debug('@@@@@imageLevelThresholds' + imageLevelThresholds);
        if(Test.isRunningTest()){
            setImageLevelThresholds(imageLevelThresholds);
        }
        return imageLevelThresholds;
    }
    
    public List<ASI_CRM_Volume_Potential_Threshold__c> getVolumePotentialThresholds (String groupOutletType){
        volumePotentialThresholds = new List<ASI_CRM_Volume_Potential_Threshold__c>();
        String recordTypeId = Global_RecordTypeCache.getRTId('ASI_CRM_Volume_Potential_Threshold__cASI_CRM_MY_Gross_Sale');
        
        volumePotentialThresholds = [SELECT ASI_CRM_SG_Volume_Potential_Name__c, ASI_CRM_SG_Min_Weight__c, RecordTypeId
                                FROM ASI_CRM_Volume_Potential_Threshold__c
                                WHERE RecordTypeId =: recordTypeId
                                AND ASI_CRM_Region__c =: this.prosSegmentation.Region__c
                                ORDER BY ASI_CRM_SG_Min_Weight__c];
        if(Test.isRunningTest()){
            setVolumePotentialThresholds(volumePotentialThresholds);
        }
        return volumePotentialThresholds;
    }
    
    /*public ASI_CRMGroup_Outlet_Type__c getGroupOutletTypeInfo()
    {
        ASI_CRM_SG_Group_Outlet_Type__c groupOutletTypeInfo = null;
        if (prosSegmentation != null){
            groupOutletTypeInfo = [SELECT Id, ASI_CRM_SG_Name__c, 
                                    ASI_CRM_SG_Image_Criteria_Set__r.Id, ASI_CRM_SG_Volume_Criteria_Set__r.Id
                                    FROM ASI_CRM_Group_Outlet_Type__c
                                    WHERE ASI_CRM_SG_Affiliate__r.Id=:prosSegmentation.ASI_CRM_SG_Affiliate__r.Id
                                    AND ASI_CRM_SG_Name__c=:prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c];
        }
    }*/
    
    public Component.Apex.OutputPanel getCustomForm()
    {
        Component.Apex.OutputPanel customForm  = new Component.Apex.OutputPanel();
        if(criteriaSheetReadyFlag){
            customForm.layout = 'block';
            customForm.styleClass='requiredInput';
            
            //ASI_CRM_SG_CriteriaManager mgr = new ASI_CRM_SG_CriteriaManager();
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
                    Component.Apex.PageBlockSection subPanel = mgr.newClassInstance(
                    criteriaThresholds.get(key).RecordTypeId).getCriteriaComponent(this.prosSegmentation.ASI_CRM_SG_Customer__r.Id, criteriaThresholds.get(key), 
                    criteriaAnswers.get(key), 
                    target, initValue);
                    
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
    
    public PageReference cancel(){
        PageReference pageRef = null;
        pageRef = new PageReference('/apex/ASI_CRM_MY_ProsSegmentationPage?id=' + this.standardController.getId());  
        pageRef.setRedirect(true); 
        return pageRef;
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
                    
                    /*
                    Remove this part, deletion is already done on trigger
                    if (sheetType == IMAGE_LEVEL){
                        ASI_CRM_SG_Pros_Image_Level__c[] oldImageLevelCriteria = [SELECT Id FROM ASI_CRM_Pros_Image_Level__c
                                     WHERE ASI_CRM_SG_Pros_Segmentation__r.Id =: this.standardController.getId()]; 
                        //deleteResults = Database.delete(oldImageLevelCriteria);
            
                    }
                    else if (sheetType == VOLUME_POTENTIAL){
                        ASI_CRM_SG_Pros_Volume_Potential__c[] oldVolumePotentialCriteria = [SELECT Id FROM ASI_CRM_Pros_Volume_Potential__c
                                     WHERE ASI_CRM_SG_Pros_Segmentation__r.Id =: this.standardController.getId()]; 
                        //deleteResults = Database.delete(oldVolumePotentialCriteria);
                    }
                    */
                    List<ASI_CRM_Pros_Image_Level__c> deleteImageLevels = new List<ASI_CRM_Pros_Image_Level__c>();
                    for (String key: answerSheet.keySet()){
                        if (sheetType == IMAGE_LEVEL && criteriaThresholds.containsKey(key)){
                            ASI_CRM_Pros_Image_Level__c deleteAccountCriteria = new ASI_CRM_Pros_Image_Level__c();
        					deleteAccountCriteria = imageLevelMap.get(key);
                            deleteImageLevels.add(deleteAccountCriteria);
                            
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
                
                    //Database update
                    //
                    
                   // ASI_CRM_SG_Account__c tempEuAccount = [select id, ASI_CRM_SG_force_iconic_account__c FROM ASI_CRM_account__c where id =: this.prosSegmentation.ASI_CRM_SG_account__c];
                    
                   // Boolean forceIconic = (tempEuAccount != null && tempEuAccount.ASI_CRM_SG_force_iconic_account__c);
                     
                        
                    if (sheetType == IMAGE_LEVEL){
                        System.debug('Upsert: ' + imageLevelMap.values());
                        System.debug('&&THISTOTALIMAGE' + this.total);
                        //insertResults = Database.insert(this.newImageLevels);
                        if(deleteImageLevels.size() > 0 && deleteImageLevels != null){
                        	//delete deleteImageLevels;
                        }
                        
                        
                       	Database.upsert(this.newImageLevels);
                        System.debug('Flag - IMAGE_LEVEL INSERT RESULT' + insertResults);
                        ASI_CRM_Image_Level_Threshold__c image_level_threshold = retrieveTheImageLevel(this.total, this.prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c);
                        this.prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c = image_level_threshold.Id;
                        this.prosSegmentation.ASI_CRM_SG_Image_Level__c = image_level_threshold.ASI_CRM_SG_Image_Level__r.Id;
                        this.prosSegmentation.ASI_CRM_SG_Is_Image_Level_Modified__c = false;
 
                        
                        System.debug('Flag - IMAGE_LEVEL PROS UPSERT RESULT' + upsertResults);
                        
                        System.debug('Flag - IMAGE_LEVEL' + this.prosSegmentation +'--'+ this.newImageLevels);
                        System.debug('Flag - ASI_CRM_SG_Outlet_Type__c' + this.prosSegmentation.ASI_CRM_SG_Outlet_Type__c);
                        
                        ASI_CRM_PROS_OutPriCon__c  outlet_prioritization = 
                            [SELECT Id, ASI_CRM_MY_Outlet_Prioritization__c
                             FROM ASI_CRM_PROS_OutPriCon__c 
                             WHERE ASI_CRM_Image_Level__c  =: image_level_threshold.ASI_CRM_SG_Image_Level__c
                             AND ASI_CRM_Outlet_Type__c =: this.prosSegmentation.ASI_CRM_SG_Outlet_Type__c
                             LIMIT 1];
                       	System.debug('Flag - list_outlet_prioritization' + outlet_prioritization);
                        
                        //this.prosSegmentation.ASI_CRM_OutletPrioritization__c = outlet_prioritization.Id;
                        this.prosSegmentation.ASI_CRM_OP__c = outlet_prioritization.ASI_CRM_MY_Outlet_Prioritization__c;
						
                        upsertResults = Database.update(this.prosSegmentation);
				                        
                    }
                    else if (sheetType == VOLUME_POTENTIAL){
                        System.debug('Upsert: ' + volumePotentialMap.values());
                        Database.insert(this.newVolumePotentials);
                        system.debug('&&THISTOTAL' + this.total);
                        this.prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c = retrieveVolumePotential(this.total, this.prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c);
                        this.prosSegmentation.ASI_CRM_SG_Is_Volume_Potential_Modified__c = false;
                        Database.update(this.prosSegmentation);
                        
                        system.debug('***VOLUME_POTENTIAL' + this.prosSegmentation.ASI_CRM_SG_Volume_Potential__c);
                    }
                    
                    System.debug('Pros Segmentation:' + this.prosSegmentation);
                    
                    /*
                    if(deleteResults != null)
                    for(Database.Deleteresult sr:deleteResults)
                    {
                        if(!sr.isSuccess())  
                        {
                            isSaved = false;
                            break;
                        }
                    }
                    */
                    
                    if (isSaved){
                        pageRef = new PageReference('/apex/ASI_CRM_MY_ProsSegmentationPage?id=' + this.standardController.getId());  
                        pageRef.setRedirect(true); 
                    }
                
                }
                catch(Exception e){
                    System.debug('Upsert Error: ' + e);
                    pageRef = null;
                    Database.rollback(pSavepoint);      
                    String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
                    //System.debug('Flag- Saving Error Info: ' + e.getTypeName() +'|'+e.getDmlType(0));
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
        
        System.debug('PageRef on Save:' + pageRef);
        return pageRef;
    }
    
    private ASI_CRM_Pros_Image_Level__c saveImageLevel(String key){
       	// ASI_CRM_SG_CriteriaManager mgr = new ASI_CRM_SG_CriteriaManager();
        system.debug('###KEY' + key);
        
        ASI_CRM_Pros_Image_Level__c accountCriteria = new ASI_CRM_Pros_Image_Level__c();
        accountCriteria = imageLevelMap.get(key);
        if(accountCriteria != null){
            accountCriteria = imageLevelMap.get(key);
            accountCriteria.ASI_CRM_SG_Criteria_Threshold__c = key;
            accountCriteria.ASI_CRM_SG_Answer__c = answerSheet.get(key);     
        }
        else{
            Id PILId = Global_RecordTypeCache.getRtId('ASI_CRM_Pros_Image_Level__cASI_CRM_MY_Pros_Image_Level');
            // accountCriteria = null;
            accountCriteria = new ASI_CRM_Pros_Image_Level__c();
            accountCriteria.ASI_CRM_SG_Criteria_Threshold__c = key;
            accountCriteria.ASI_CRM_SG_Answer__c = answerSheet.get(key);
            accountCriteria.ASI_CRM_SG_Pros_Segmentation__c = this.standardController.getId();
            accountCriteria.RecordTypeId = PILId;
        }
        // accountCriteria.ASI_CRM_SG_Is_Mass_Update__c = true;        
        System.debug('Flag - On Save Criteria Threshold:' + criteriaThresholds.get(key).ASI_CRM_SG_Question__c + '|' + answerSheet.get(key) + '|' + criteriaAnswers.get(key));
        //System.debug(criteriaAnswers.get(key).Recordtype);
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
    
    /*
    private String retrieveImageLevel (Double score, String groupOutletType){
        system.debug('@@@groupOutletTypeImg' + groupOutletType);
        List<ASI_CRM_Image_Level_Threshold__c>imageLevels = this.getImageLevelThresholds(groupOutletType);
        String imageName = '';
        
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
	*/
    
    private ASI_CRM_Image_Level_Threshold__c retrieveTheImageLevel (Double score, String groupOutletType){
        system.debug('@@@groupOutletTypeImg' + groupOutletType);
        List<ASI_CRM_Image_Level_Threshold__c>imageLevels = this.getImageLevelThresholds(groupOutletType);
        ASI_CRM_Image_Level_Threshold__c imageName = new ASI_CRM_Image_Level_Threshold__c();
        
        if(imageLevels != null){
            if (score > imageLevels[imageLevels.size()-1].ASI_CRM_SG_Min_Weight__c){
                imageName = imageLevels[imageLevels.size()-1];
            }else{
                for (Integer i=0; i<imageLevels.size(); i++){
                    Double left = imageLevels[i].ASI_CRM_SG_Min_Weight__c;
                    Double right = imageLevels[i].ASI_CRM_SG_Min_Weight__c;
                    if (imageLevels.size()-1 != i)
                        right = imageLevels[i+1].ASI_CRM_SG_Min_Weight__c;
                
                    if(left == score || score<right) 
                    {
                        //System.debug('1 - '+n+':' + x +'('+s[x]+')'); break;
                        imageName = imageLevels[i];
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
            
                if(left == score || score<right) 
                {
                    //System.debug('1 - '+n+':' + x +'('+s[x]+')'); break;
                    volumeLevel = volumePotentials[i].Id;
                    
                    break;
                }
                else if (score>right)
                {
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
        //return null;
    }
    
}