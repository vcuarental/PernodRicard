public with sharing class EUR_CRM_CriteriaController {
	
    private final static String RU_PROS_SEGMENTATION_RT = 'EUR_RU_PROS_Segmentation';
    
    private final Integer IMAGE_LEVEL = 1;
    private final Integer VOLUME_POTENTIAL = 2;
    private Integer sheetType{set; get;}
    private ApexPages.StandardController standardController;
    private EUR_CRM_CriteriaManager mgr {get;set;}
    private Double total;
    
    private EUR_CRM_Pros_Segmentation__c prosSegmentation;
    private EUR_CRM_Criteria_Set__c criteriaSetInfo;
    private EUR_CRM_Group_Outlet_Type__c groupOutletTypeInfo;
    private Map<Id, EUR_CRM_Criteria_Threshold__c> criteriaThresholds;
    private List<EUR_CRM_Criteria_Threshold__c> criteriaThresholdsList{get;set;}
    private List<EUR_CRM_Criteria_Answer__c> answers;
    private Map<Id, List<EUR_CRM_Criteria_Answer__c>> criteriaAnswers;
    private Map<Id, EUR_CRM_Pros_Image_Level__c> imageLevelMap{get;set;}{imageLevelMap = new Map<Id, EUR_CRM_Pros_Image_Level__c>();}
    private Map<Id, EUR_CRM_Pros_Volume_Potential__c> volumePotentialMap{get;set;}{volumePotentialMap = new Map<Id, EUR_CRM_Pros_Volume_Potential__c>();}
    //12/11/2014 - Reference junction objs Image Level and Volume Potential Thresholds
    private List<EUR_CRM_Image_Level_Threshold__c> imageLevelThresholds;
    private List<EUR_CRM_Volume_Potential_Threshold__c> volumePotentialThresholds;
    
    private List<EUR_CRM_Pros_Image_Level__c>newImageLevels;
    private List<EUR_CRM_Pros_Volume_Potential__c>newVolumePotentials;
    
    private Map<String, String> answerLabelValueMapping;
    
    public Map<Id, String> answerSheet{get;set;}
    //public String formTitle{set; get;}
    //public String formHeader{set; get;}
    //public String formFooter{set; get;}
    public Boolean criteriaSheetReadyFlag{get;set;}{criteriaSheetReadyFlag=false;}
    
    public EUR_CRM_CriteriaController(ApexPages.StandardController standardController){
        this.standardController = standardController;
        this.sheetType = Integer.valueOf(ApexPages.currentPage().getParameters().get('type'));
        System.debug('Type' + sheetType);
        
        mgr = new EUR_CRM_CriteriaManager();

        //System.debug('Check Pros Segmentation:' + this.standardController.Id+'|'+this.standardController.EUR_CRM_Affiliate__r.Id+'|'+this.standardController.EUR_CRM_Group_Outlet_Type__c);
        imageLevelMap = new Map<Id, EUR_CRM_Pros_Image_Level__c>();
        volumePotentialMap = new Map<Id, EUR_CRM_Pros_Volume_Potential__c>();
        
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
            getAnswerLabelValueMapping();
            returnAnswerSheet();
            
            if (sheetType == IMAGE_LEVEL){
                returnImageLevelMap();
            }
            else if (sheetType == VOLUME_POTENTIAL){
                returnVolumePotentialMap();
            }
            
            this.newImageLevels = new List<EUR_CRM_Pros_Image_Level__c>();
            this.newVolumePotentials = new List<EUR_CRM_Pros_Volume_Potential__c>();
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
                                EUR_CRM_Account__c, EUR_CRM_Account__r.Id, 
                                EUR_CRM_Standard_Account__c, EUR_CRM_Standard_Account__r.Id,
                                EUR_CRM_Affiliate__r.Id, 
                                EUR_CRM_Group_Outlet_Type__c, EUR_CRM_Outlet_Type__c,
                                EUR_CRM_Image_Level__c, EUR_CRM_Volume_Potential__c,
                                EUR_CRM_Country_Code__c, EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Name__c, 
                                RecordType.DeveloperName
                                FROM EUR_CRM_Pros_Segmentation__c
                                WHERE Id =: this.standardController.getId() LIMIT 1
                                ];
                                
            System.debug('prosSegmentation:'+prosSegmentation); 
        }
        //return prosSegmentation;
        this.groupOutletTypeInfo = null;
        if (prosSegmentation != null && prosSegmentation.EUR_CRM_Group_Outlet_Type__c!=null){
            //Baltics - Modified query for country specific
            groupOutletTypeInfo = [SELECT Id, EUR_CRM_Group_Outlet_Name__c, 
                                    EUR_CRM_Image_Criteria_Set__r.Id, EUR_CRM_Volume_Criteria_Set__r.Id,
                                    EUR_CRM_Country_Code__c
                                    FROM EUR_CRM_Group_Outlet_Type__c
                                    WHERE Id =: prosSegmentation.EUR_CRM_Group_Outlet_Type__c];

            System.debug('groupOutletTypeInfo:'+groupOutletTypeInfo);
        }
        criteriaSetInfo = null;
        if(groupOutletTypeInfo != null){
            List<EUR_CRM_Criteria_Set__c> tempCriteriaSet = new List<EUR_CRM_Criteria_Set__c>();
            //TODO Change filter to Group Outlet Type and Affiliate ID
            //TODO RECORD TYPE, IMAGE LEVEL AND VOL POTENTIAL
            if (this.sheetType == IMAGE_LEVEL){
            tempCriteriaSet = [SELECT Id, EUR_CRM_Name__c
                                //EUR_CRM_Header_Message__c, EUR_CRM_Footer_Message__c, EUR_CRM_Title__c
                                FROM EUR_CRM_Criteria_Set__c WHERE Id =: groupOutletTypeInfo.EUR_CRM_Image_Criteria_Set__r.Id LIMIT 1];
            }
            else if (this.sheetType == VOLUME_POTENTIAL){
            tempCriteriaSet = [SELECT Id, EUR_CRM_Name__c
                                //EUR_CRM_Header_Message__c, EUR_CRM_Footer_Message__c, EUR_CRM_Title__c
                                FROM EUR_CRM_Criteria_Set__c WHERE Id =: groupOutletTypeInfo.EUR_CRM_Volume_Criteria_Set__r.Id LIMIT 1];
            }
                                
            System.debug('tempCriteriaSet:' + tempCriteriaSet);
            if (tempCriteriaSet.size()> 0){
                criteriaSetInfo = tempCriteriaSet[0];
                //formTitle = criteriaSetInfo.EUR_CRM_Title__c;
                //formHeader = criteriaSetInfo.EUR_CRM_Header_Message__c;
                //formFooter = criteriaSetInfo.EUR_CRM_Footer_Message__c;
            }
            
            System.debug('getCriteriaSetInfo:'+criteriaSetInfo);
            
            prosSegmentationFlag = true;
        }
        
        return prosSegmentationFlag;
    }

    //SETTER
    public void setCriteriaSetInfo(EUR_CRM_Criteria_Set__c criteriaSetInfo)
    {
        this.criteriaSetInfo = criteriaSetInfo;
    }
    public void setCriteriaThreshold(Map<Id, EUR_CRM_Criteria_Threshold__c> criteriaThresholds)
    {
        this.criteriaThresholds = criteriaThresholds;
    }
    public void setCriteriaAnswers(Map<Id, List<EUR_CRM_Criteria_Answer__c>> criteriaAnswers)
    {
        this.criteriaAnswers = criteriaAnswers;
    }
    public void setAnswers(List<EUR_CRM_Criteria_Answer__c> answers)
    {
        this.answers = answers;
    }
    /*public void setAnswerSheet(Map<Id, String> answerSheet){
        this.answerSheet = answerSheet;
    }*/
    public void setImageLevelThresholds (List<EUR_CRM_Image_Level_Threshold__c> imageLevelThresholds){
        this.imageLevelThresholds = imageLevelThresholds;
    }
    public void setVolumePotentialThresholds (List<EUR_CRM_Volume_Potential_Threshold__c> volumePotentialThresholds){
        this.volumePotentialThresholds = volumePotentialThresholds;
    }
       
    public Map<Id, EUR_CRM_Criteria_Threshold__c> getCriteriaThresholds()
    {   
        System.debug('Flag 2 getCriteriaSetInfo:'+criteriaSetInfo);
        criteriaThresholds = new  Map<Id, EUR_CRM_Criteria_Threshold__c>();
        if (criteriaSetInfo !=null)
        {
            /*criteriaThresholds = new Map<Id, EUR_CRM_Criteria_Threshold__c>(
                                    [SELECT Id, RecordTypeId,
                                    EUR_CRM_Question__c, EUR_CRM_Weight__c
                                    FROM EUR_CRM_Criteria_Threshold__c 
                                    WHERE EUR_CRM_Criteria_Set__r.Id=:criteriaSetInfo.Id]);*/    
                criteriaThresholdsList = [SELECT Id, RecordTypeId,
                                    EUR_CRM_Question__c, EUR_CRM_Weight__c,
                                    EUR_CRM_Criteria_Order__c
                                    FROM EUR_CRM_Criteria_Threshold__c 
                                    WHERE EUR_CRM_Criteria_Set__r.Id=:criteriaSetInfo.Id
                                    ORDER BY EUR_CRM_Sequence__c, EUR_CRM_Criteria_Order__c, CreatedDate];
                                    
            for (EUR_CRM_Criteria_Threshold__c ct: criteriaThresholdsList) {
                criteriaThresholds.put(ct.Id, ct);
            }
        }
        System.debug('getCriteriaThresholds:'+criteriaThresholds);
        return criteriaThresholds;
    }
    public List<EUR_CRM_Criteria_Answer__c> getAnswers()
    {
        System.debug('Flag 2 getCriteriaThresholds:'+criteriaThresholds);
        answers = new List<EUR_CRM_Criteria_Answer__c>();
        if (criteriaThresholds.size()>0)
        {
            answers = [SELECT Id, RecordTypeId, Recordtype.DeveloperName,
                        EUR_CRM_Value__c, 
                        EUR_CRM_Base_Currency__c, EUR_CRM_Base_Integer__c,
                        EUR_CRM_Condition__c, EUR_CRM_Criteria_Threshold__r.Id,
                        EUR_CRM_Label__c, EUR_CRM_Weight__c
                        FROM EUR_CRM_Criteria_Answer__c 
                        WHERE EUR_CRM_Criteria_Threshold__r.Id in: criteriaThresholds.keySet() 
                        ORDER BY EUR_CRM_Base_Integer__c desc, EUR_CRM_Base_Currency__c desc, EUR_CRM_Label__c];
         }
        System.debug('getAnswers:'+answers);
          System.debug('getAnswersSize:'+answers.size());
        return answers;
    }
    
    public Map<Id, List<EUR_CRM_Criteria_Answer__c>> getCriteriaAnswers()
    {
        System.debug('Flag 2 getAnswers:'+answers);
        criteriaAnswers = new Map<Id, List<EUR_CRM_Criteria_Answer__c>>();
        if (answers.size()>0)
        {
            for (EUR_CRM_Criteria_Answer__c ans: answers){
                List<EUR_CRM_Criteria_Answer__c> criteriaAnsList = new List<EUR_CRM_Criteria_Answer__c>();
                if (criteriaAnswers.containsKey(ans.EUR_CRM_Criteria_Threshold__r.Id)){
                    criteriaAnsList = criteriaAnswers.get(ans.EUR_CRM_Criteria_Threshold__r.Id);
                }
                criteriaAnsList.add(ans);
                criteriaAnswers.put(ans.EUR_CRM_Criteria_Threshold__r.Id, criteriaAnsList);
            }
        }
        System.debug('getCriteriaAnswers:'+criteriaAnswers);
        return criteriaAnswers;
    }
    
    public void getAnswerLabelValueMapping() {
        answerLabelValueMapping = new Map<String, String>();
        for(Id key : criteriaAnswers.keySet()) {
            List<EUR_CRM_Criteria_Answer__c> criteriaAnswerList = criteriaAnswers.get(key);
            for(EUR_CRM_Criteria_Answer__c criteriaAnswer : criteriaAnswerList) {
                if(String.isNotBlank(criteriaAnswer.EUR_CRM_Label__c) && String.isNotBlank(criteriaAnswer.EUR_CRM_Value__c)) {
                    answerLabelValueMapping.put(key + ':' + criteriaAnswer.EUR_CRM_Label__c, criteriaAnswer.EUR_CRM_Value__c);
                    answerLabelValueMapping.put(key + ':' + criteriaAnswer.EUR_CRM_Value__c, criteriaAnswer.EUR_CRM_Label__c);
                }
            }
        }
    }
    
    public Map<Id,  EUR_CRM_Pros_Image_Level__c> returnImageLevelMap(){
        //imageLevelMap = new Map<Id,  EUR_CRM_Pros_Image_Level__c>();
        
        if (this.standardController.getId() != null)
        {
            List<EUR_CRM_Pros_Image_Level__c> prosImageLevels = [SELECT Id, EUR_CRM_Criteria_Threshold__r.Id, 
                            EUR_CRM_Weight__c, EUR_CRM_Answer__c
                            FROM EUR_CRM_Pros_Image_Level__c
                            WHERE EUR_CRM_Pros_Segmentation__r.Id =: this.standardController.getId()];
                            
            for(EUR_CRM_Pros_Image_Level__c prosImageLevel: prosImageLevels)
            {
                imageLevelMap.put(prosImageLevel.EUR_CRM_Criteria_Threshold__r.Id, prosImageLevel);
                String answer = prosImageLevel.EUR_CRM_Answer__c == null ? '' : prosImageLevel.EUR_CRM_Answer__c;
                if(prosSegmentation.RecordType.DeveloperName == RU_PROS_SEGMENTATION_RT) {
                    if(String.isNotBlank(answer)) {
                        answer = answerLabelValueMapping.get(prosImageLevel.EUR_CRM_Criteria_Threshold__r.Id + ':' + answer) == null ? 
                                 answer : answerLabelValueMapping.get(prosImageLevel.EUR_CRM_Criteria_Threshold__r.Id + ':' + answer);
                    }
                }
                answerSheet.put(prosImageLevel.EUR_CRM_Criteria_Threshold__r.Id, answer);
            }             
            /*imageLevelMap = new Map<Id, EUR_CRM_Pros_Image_Level__c>(
                            [SELECT Id, EUR_CRM_Criteria_Threshold__r.Id, 
                            EUR_CRM_Weight__c, EUR_CRM_Answer__c
                            FROM EUR_CRM_Pros_Image_Level__c
                            WHERE EUR_CRM_Pros_Segmentation__r.Id =: this.standardController.getId()]);*/
        }
        system.debug('!!!' + imageLevelMap.size());
        return imageLevelMap;
    }
       
    public Map<Id,  EUR_CRM_Pros_Volume_Potential__c> returnVolumePotentialMap()
    {
        //volumePotentialMap = new Map<Id,  EUR_CRM_Pros_Volume_Potential__c>();
        
        if (this.standardController.getId() != null)
        {
            List<EUR_CRM_Pros_Volume_Potential__c> prosVolumePotentials = [SELECT Id, EUR_CRM_Criteria_Threshold__r.Id, 
                            EUR_CRM_Weight__c, EUR_CRM_Answer__c
                            FROM EUR_CRM_Pros_Volume_Potential__c
                            WHERE EUR_CRM_Pros_Segmentation__r.Id =: this.standardController.getId()];
                            
            for(EUR_CRM_Pros_Volume_Potential__c prosVolumePotential: prosVolumePotentials)
            {
                volumePotentialMap.put(prosVolumePotential.EUR_CRM_Criteria_Threshold__r.Id, prosVolumePotential);
                answerSheet.put(prosVolumePotential.EUR_CRM_Criteria_Threshold__r.Id, (prosVolumePotential.EUR_CRM_Answer__c==null)?'':prosVolumePotential.EUR_CRM_Answer__c);
            }    
            /*volumePotentialMap = new Map<Id, EUR_CRM_Pros_Volume_Potential__c>(
                            [SELECT Id, EUR_CRM_Criteria_Threshold__r.Id, 
                            EUR_CRM_Weight__c, EUR_CRM_Answer__c
                            FROM EUR_CRM_Pros_Volume_Potential__c
                            WHERE EUR_CRM_Pros_Segmentation__r.Id =: this.standardController.getId()]);*/
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
    
    public List<EUR_CRM_Image_Level_Threshold__c> getImageLevelThresholds(String groupOutletType){
        imageLevelThresholds = new List<EUR_CRM_Image_Level_Threshold__c>();
        
        /*imageLevelThresholds = [SELECT EUR_CRM_Name__c, EUR_CRM_Min_Weight__c 
                                FROM EUR_CRM_Image_Level__c
                                WHERE EUR_CRM_Group_Outlet_Type__c =: groupOutletType
                                ORDER BY EUR_CRM_Min_Weight__c];*/
                                
        imageLevelThresholds = [SELECT EUR_CRM_Image_Level_Name__c, EUR_CRM_Min_Weight__c 
                                FROM EUR_CRM_Image_Level_Threshold__c
                                WHERE EUR_CRM_Group_Outlet_Type__c =: groupOutletType
                                ORDER BY EUR_CRM_Min_Weight__c];
        System.debug('ImageLevelThreshold query - groupOutlet Type:' + groupOutletType);
        system.debug('@@@@@imageLevelThresholds' + imageLevelThresholds);
        return imageLevelThresholds;
    }
    
    public List<EUR_CRM_Volume_Potential_Threshold__c> getVolumePotentialThresholds (String groupOutletType){
        volumePotentialThresholds = new List<EUR_CRM_Volume_Potential_Threshold__c>();
        
        volumePotentialThresholds = [SELECT EUR_CRM_Volume_Potential_Name__c, EUR_CRM_Min_Weight__c 
                                FROM EUR_CRM_Volume_Potential_Threshold__c
                                WHERE EUR_CRM_Group_Outlet_Type__c =: groupOutletType
                                ORDER BY EUR_CRM_Min_Weight__c];
        
        return volumePotentialThresholds;
    }
    
    /*public EUR_CRM_Group_Outlet_Type__c getGroupOutletTypeInfo()
    {
        EUR_CRM_Group_Outlet_Type__c groupOutletTypeInfo = null;
        if (prosSegmentation != null){
            groupOutletTypeInfo = [SELECT Id, EUR_CRM_Name__c, 
                                    EUR_CRM_Image_Criteria_Set__r.Id, EUR_CRM_Volume_Criteria_Set__r.Id
                                    FROM EUR_CRM_Group_Outlet_Type__c
                                    WHERE EUR_CRM_Affiliate__r.Id=:prosSegmentation.EUR_CRM_Affiliate__r.Id
                                    AND EUR_CRM_Name__c=:prosSegmentation.EUR_CRM_Group_Outlet_Type__c];
        }
    }*/
    
    public Component.Apex.OutputPanel getCustomForm()
    {
        Component.Apex.OutputPanel customForm  = new Component.Apex.OutputPanel();
        if(criteriaSheetReadyFlag){
            customForm.layout = 'block';
            customForm.styleClass='requiredInput';
            
            //EUR_CRM_CriteriaManager mgr = new EUR_CRM_CriteriaManager();
            if(criteriaAnswers.size()>0){
                System.debug('Flag - Answer sheet: ' + answerSheet);
                
                for (EUR_CRM_Criteria_Threshold__c ct : criteriaThresholdsList){
                    Id key = ct.Id;
                    String target = '{!answerSheet["'+key+'"]}';
                    String initValue = '';
                    
                    if(!answerSheet.containsKey(key) || (answerSheet.containsKey(key) && answerSheet.get(key)==null))
                            answerSheet.put(key, '');
                         
                    if(answerSheet.containsKey(key))
                            initValue = answerSheet.get(key);
                    system.debug('Init value:::' + initValue);        
                    Component.Apex.PageBlockSection subPanel = mgr.newClassInstance(
                    criteriaThresholds.get(key).RecordTypeId).getCriteriaComponent(this.prosSegmentation.EUR_CRM_country_code__c == 'PRT'?this.prosSegmentation.EUR_CRM_Standard_Account__r.Id : this.prosSegmentation.EUR_CRM_Account__r.Id, criteriaThresholds.get(key), 
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
                        EUR_CRM_Pros_Image_Level__c[] oldImageLevelCriteria = [SELECT Id FROM EUR_CRM_Pros_Image_Level__c
                                     WHERE EUR_CRM_Pros_Segmentation__r.Id =: this.standardController.getId()]; 
                        //deleteResults = Database.delete(oldImageLevelCriteria);
            
                    }
                    else if (sheetType == VOLUME_POTENTIAL){
                        EUR_CRM_Pros_Volume_Potential__c[] oldVolumePotentialCriteria = [SELECT Id FROM EUR_CRM_Pros_Volume_Potential__c
                                     WHERE EUR_CRM_Pros_Segmentation__r.Id =: this.standardController.getId()]; 
                        //deleteResults = Database.delete(oldVolumePotentialCriteria);
                    }
                    */
                    for (String key: answerSheet.keySet()){
                        if (sheetType == IMAGE_LEVEL && criteriaThresholds.containsKey(key)){
                            EUR_CRM_Pros_Image_Level__c accountCriteria = saveImageLevel(key);
                            System.debug('Flag - Save - Check Account Criteria:' + accountCriteria);
                            if (accountCriteria != null){
                                this.total += accountCriteria.EUR_CRM_Weight__c;
                            }
                        }
                        else if (sheetType == VOLUME_POTENTIAL && criteriaThresholds.containsKey(key)){
                            EUR_CRM_Pros_Volume_Potential__c accountCriteria = saveVolumePotential(key);
                            if (accountCriteria != null){
                                this.total += accountCriteria.EUR_CRM_Weight__c;
                            }
                        }
                    }
                
                    //Database update
                    //
                    
                   // EUR_CRM_Account__c tempEuAccount = [select id, eur_crm_force_iconic_account__c from eur_crm_account__c where id =: this.prosSegmentation.eur_crm_account__c];
                    
                   // Boolean forceIconic = (tempEuAccount != null && tempEuAccount.eur_crm_force_iconic_account__c);
                     
                        
                    if (sheetType == IMAGE_LEVEL){
                        System.debug('Upsert: ' + imageLevelMap.values());
                        System.debug('&&THISTOTALIMAGE' + this.total);
                        insertResults = Database.insert(this.newImageLevels);
                        System.debug('Flag - IMAGE_LEVEL INSERT RESULT' + insertResults);
                        
                        this.prosSegmentation.EUR_CRM_Image_Level_Threshold__c = retrieveImageLevel(this.total, this.prosSegmentation.EUR_CRM_Group_Outlet_Type__c);
                        this.prosSegmentation.EUR_CRM_Is_Image_Level_Modified__c = false;
 
                        upsertResults = Database.update(this.prosSegmentation);
                        System.debug('Flag - IMAGE_LEVEL PROS UPSERT RESULT' + upsertResults);
                        
                        System.debug('Flag - IMAGE_LEVEL' + this.prosSegmentation +'--'+ this.newImageLevels);
                        
                    }
                    else if (sheetType == VOLUME_POTENTIAL){
                        System.debug('Upsert: ' + volumePotentialMap.values());
                        Database.insert(this.newVolumePotentials);
                        system.debug('&&THISTOTAL' + this.total);
                        this.prosSegmentation.EUR_CRM_Volume_Potential_Threshold__c = retrieveVolumePotential(this.total, this.prosSegmentation.EUR_CRM_Group_Outlet_Type__c);
                        this.prosSegmentation.EUR_CRM_Is_Volume_Potential_Modified__c = false;
                        Database.update(this.prosSegmentation);
                        
                        system.debug('***VOLUME_POTENTIAL' + this.prosSegmentation.EUR_CRM_Volume_Potential__c);
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
                        pageRef = new PageReference('/' + this.standardController.getId());  
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
    
    private EUR_CRM_Pros_Image_Level__c saveImageLevel(String key){
       // EUR_CRM_CriteriaManager mgr = new EUR_CRM_CriteriaManager();
       system.debug('###KEY' + key);
        EUR_CRM_Pros_Image_Level__c accountCriteria = null;
        accountCriteria = new EUR_CRM_Pros_Image_Level__c();
        accountCriteria.EUR_CRM_Criteria_Threshold__c = key;
	
        String answer = answerSheet.get(key);
    	if(prosSegmentation.RecordType.DeveloperName == RU_PROS_SEGMENTATION_RT) {
            answer = answerLabelValueMapping.get(key + ':' + answer) == null ? 
                     answer : answerLabelValueMapping.get(key + ':' + answer);
        }
        
        accountCriteria.EUR_CRM_Answer__c = answer;   
        
        accountCriteria.EUR_CRM_Pros_Segmentation__c = this.standardController.getId();
       // accountCriteria.EUR_CRM_Is_Mass_Update__c = true;        
        System.debug('Flag - On Save Criteria Threshold:' + criteriaThresholds.get(key).EUR_CRM_Question__c + '|' + answerSheet.get(key) + '|' + criteriaAnswers.get(key));
        //System.debug(criteriaAnswers.get(key).Recordtype);
        List<EUR_CRM_Criteria_Answer__c> ansList = criteriaAnswers.get(key);
        ansList.sort();
        System.debug('FLAG - Save Image Level - Check Answer Options:'+criteriaThresholds.get(key).RecordTypeId+'-'+ ansList + '-' +answerSheet.get(key));
        Double answerWeight = mgr.newClassInstance(
            criteriaThresholds.get(key).RecordTypeId).calculateCriteria((Double)criteriaThresholds.get(key).EUR_CRM_Weight__c, 
            ansList, 
            answerSheet.get(key));
        
        accountCriteria.EUR_CRM_Weight__c = answerWeight;
        
        

        this.newImageLevels.add(accountCriteria);
        
        return accountCriteria;
    }
    
    private EUR_CRM_Pros_Volume_Potential__c saveVolumePotential(String key){
        //EUR_CRM_CriteriaManager mgr = new EUR_CRM_CriteriaManager();
        EUR_CRM_Pros_Volume_Potential__c accountCriteria = null;
        //if (!volumePotentialMap.containsKey(key)){
            accountCriteria = new EUR_CRM_Pros_Volume_Potential__c();
            accountCriteria.EUR_CRM_Criteria_Threshold__c = key;
            accountCriteria.EUR_CRM_Answer__c = answerSheet.get(key);
            accountCriteria.EUR_CRM_Pros_Segmentation__c = this.standardController.getId();
          //  accountCriteria.EUR_CRM_Is_Mass_Update__c = true;
            volumePotentialMap.put(key, accountCriteria);
        //}else{
            //accountCriteria = volumePotentialMap.get(key);
            //accountCriteria.EUR_CRM_Answer__c = answerSheet.get(key);
        //}
        //Get answer weight (Threshold weight* answer weight)
        List<EUR_CRM_Criteria_Answer__c> ansList = criteriaAnswers.get(key);
        ansList.sort();
        System.debug('FLAG - Save Vol Potential - Check Answer Options:'+criteriaThresholds.get(key).RecordTypeId+'-'+ ansList + '-' +answerSheet.get(key));
        Double answerWeight = mgr.newClassInstance(
            criteriaThresholds.get(key).RecordTypeId).calculateCriteria((Double)criteriaThresholds.get(key).EUR_CRM_Weight__c, 
            ansList, 
            answerSheet.get(key));
        
        accountCriteria.EUR_CRM_Weight__c = answerWeight;
        
        this.newVolumePotentials.add(accountCriteria);
        return accountCriteria;
    }
    
    private String retrieveImageLevel (Double score, String groupOutletType){
        system.debug('@@@groupOutletTypeImg' + groupOutletType);
        List<EUR_CRM_Image_Level_Threshold__c>imageLevels = this.getImageLevelThresholds(groupOutletType);
        String imageName = '';
        
        if(imageLevels != null){
            if (score > imageLevels[imageLevels.size()-1].EUR_CRM_Min_Weight__c){
                imageName = imageLevels[imageLevels.size()-1].Id;
            }else{
                for (Integer i=0; i<imageLevels.size(); i++){
                    Double left = imageLevels[i].EUR_CRM_Min_Weight__c;
                    Double right = imageLevels[i].EUR_CRM_Min_Weight__c;
                    if (imageLevels.size()-1 != i)
                        right = imageLevels[i+1].EUR_CRM_Min_Weight__c;
                
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
    List<EUR_CRM_Volume_Potential_Threshold__c>volumePotentials = this.getVolumePotentialThresholds(groupOutletType);
    String volumeLevel = '';
    
    if(volumePotentials != null){
        if (score > volumePotentials[volumePotentials.size()-1].EUR_CRM_Min_Weight__c){
            volumeLevel = volumePotentials[volumePotentials.size()-1].Id;
            
            system.debug('%%%volumeLevel '+ volumeLevel);
        }else{
            system.debug('%%%2nd');
            for (Integer i=0; i<volumePotentials.size(); i++){
                Double left = volumePotentials[i].EUR_CRM_Min_Weight__c;
                Double right = volumePotentials[i].EUR_CRM_Min_Weight__c;
                if (volumePotentials.size()-1 != i)
                    right = volumePotentials[i+1].EUR_CRM_Min_Weight__c;
            
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