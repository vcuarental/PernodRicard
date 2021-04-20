public with sharing class EUR_CRM_PRSegmentationPageController {
    private ApexPages.StandardController standardController;

    public EUR_CRM_PRS_Segmentation__c prSegmentation           {get;set;}
    public Id prSegmentationId                                  {get;set;}
    public EUR_CRM_PRS_Group_Outlet_Type__c groupOutletType     {get;set;}

    public Boolean isPROS                                       {get;set;}
    public Boolean isPROFS                                      {get;set;}
    public Boolean isProsAdmin                                  {get;set;}
    public Boolean isAdmin                                      {get;set;}
    public Boolean hasEditAccess                                {get;set;}

    public Boolean isGroupDisabled                              {get;set;}
    public Boolean is_BBP_ButtonDisabled                        {get;set;}
    public Boolean is_BP_ButtonDisabled                         {get;set;}
    public Boolean is_IL_ButtonDisabled                         {get;set;}
    public Boolean is_VP_ButtonDisabled                         {get;set;}

    public List<String> businessPotentialLabels                 {get;set;}
    public List<String> brandBuildingPotentialLabels            {get;set;}
    public List<String> imageLevelLabels                        {get;set;}
    public List<String> volumePotentialLabels                   {get;set;}
    public Map<String, Boolean> potentialMap                    {get;set;}

    public List<EUR_CRM_PRS_Answer__c> prsBBPUserAnswers        {get;set;}
    public List<EUR_CRM_PRS_Answer__c> prsBPUserAnswers         {get;set;}
    public List<EUR_CRM_PRS_Answer__c> prsILUserAnswers         {get;set;}
    public List<EUR_CRM_PRS_Answer__c> prsVPUserAnswers         {get;set;}

    public Integer noOfRow                                      {get;set;}
    public Integer noOfCol                                      {get;set;}
    public Boolean isOutletTypeVisible                          {get;set;}

    // Aspect Types
    private final Integer BRAND_BUILDING_POTENTIAL = 1;
    private final Integer BUSINESS_POTENTIAL = 2;
    private final Integer IMAGE_LEVEL = 3;
    private final Integer VOLUME_POTENTIAL = 4;

    // EUR_CRM_PRS_Answer__c Recordtypes. Key is aspect type
    private final Map<Integer, String> prsAnswerRecordTypeMap = new Map<Integer, String>{
        BRAND_BUILDING_POTENTIAL => 'EUR_PRS_Answer_Brand_Building_Potential',
        BUSINESS_POTENTIAL => 'EUR_PRS_Answer_Business_Potential',
        IMAGE_LEVEL => 'EUR_PRS_Answer_Image_Level',
        VOLUME_POTENTIAL => 'EUR_PRS_Answer_Volume_Potential'
    };


    /*
    *    constructor
    */
    public EUR_CRM_PRSegmentationPageController(ApexPages.standardController standardController){
        // Assign the standard controller and PRSegmentation record
        this.standardController = standardController;
        prSegmentationId = standardController.getId();

        if(prSegmentationId != null) {
            // set PR Segmentation record
            setPRSegmentation();
            // set the PRS Group Outlet
            setPRSGroupOutletType();
            // Determine Permissions
            determinePermissions();
            // Initialize potential vlaues and map            
            initPotentials();
            // Initializes the User's answers List
            initAnswers();
            // Set rendering variables
            validate();
        }

    }

    /*************************************************************************************
    *   Sets the value of the prSegmentation variable and determines type of segmentation
    *   Calls the helper class to SOQL all the fields of the record + key relationship values
    *************************************************************************************/
    private void setPRSegmentation() {
        this.prSegmentation = EUR_CRM_PRSegmentationClass.returnPRSegmentationViaId(prSegmentationId);
        // Determine segmentation type
        this.isPROS = EUR_CRM_RecordTypeHelper.euAccounts_PRS_SegmentationTypeMap.get(prSegmentation.EUR_CRM_Account__r.RecordType.DeveloperName).get('isPROS');
        this.isPROFS = EUR_CRM_RecordTypeHelper.euAccounts_PRS_SegmentationTypeMap.get(prSegmentation.EUR_CRM_Account__r.RecordType.DeveloperName).get('isPROFS');
        this.isOutletTypeVisible = !EUR_CRM_RecordTypeHelper.SegmentationRecordtypesWithoutOutletTypes.contains(prSegmentation.EUR_CRM_Account__r.RecordType.DeveloperName);
    }

    /*************************************************************************************
    *   Sets the value of the groupOutletType variable
    *   Calls the helper class to SOQL all the fields of the record + key relationship values
    *************************************************************************************/
    private void setPRSGroupOutletType() {
        this.groupOutletType = EUR_CRM_PRSegmentationClass.returnPRSGroupOutletTypeViaId(prSegmentation.EUR_CRM_PRS_Group_Outlet_Type__c);
    }

    /*************************************************************************************
    *   Determines the access permissions the user has for the the PR Segmentation record
    *************************************************************************************/
    private void determinePermissions() {
        String uProfile = [SELECT name FROM Profile WHERE id =: UserInfo.getProfileID()][0].name;
        this.isAdmin = uProfile == 'System Administrator' || uProfile == 'EUR System Admin';
        this.isProsAdmin = determimeIsPRSAdmin();
        this.hasEditAccess = determineEditAccess();
        System.debug(isAdmin);
        System.debug(isProsAdmin);
        System.debug(hasEditAccess);
    }

    /*************************************************************************************
    *   Initializes the values of BBP, BPs, IL, VP
    *   retrieves the labels for both BBP, BP, IL, VP
    *             As well as constructing the potential matrix
    *************************************************************************************/
    private void initPotentials() {
        if(isPROS){
            // Retrieve the Labels of Image Level and Volume Potential            
//            this.imageLevelLabels = EUR_CRM_PRSegmentationClass.returnImageLevelLabels();
//            this.volumePotentialLabels = EUR_CRM_PRSegmentationClass.returnVolumePotentialLabels();
            this.imageLevelLabels = EUR_CRM_PRSegmentationClass.returnPicklistValuesDependOnRTidAndFieldName(
                prSegmentation.EUR_CRM_Image_Level__r.RecordTypeId, 'EUR_CRM_Segmentation_IL_Aspect_Name__c');
            this.volumePotentialLabels = EUR_CRM_PRSegmentationClass.returnPicklistValuesDependOnRTidAndFieldName(
                prSegmentation.EUR_CRM_Volume_Potential__r.RecordTypeId, 'EUR_CRM_Segmentation_VP_Aspect_Name__c');
            this.potentialMap = EUR_CRM_PRSegmentationClass.returnPROSPotentialMatrix(this.prSegmentation, this.imageLevelLabels, this.volumePotentialLabels);

            noOfRow = this.imageLevelLabels.size();
            noOfCol = this.volumePotentialLabels.size();
        }
        else if(isPROFS){
            // Retrieve the Labels of BPs and BBPs and Matrix
            this.brandBuildingPotentialLabels = EUR_CRM_PRSegmentationClass.returnPicklistValuesDependOnRTidAndFieldName(
                prSegmentation.EUR_CRM_Brand_Building_Potential__r.RecordTypeId, 'EUR_CRM_Segmentation_BBP_Aspect_Name__c');
            this.businessPotentialLabels = EUR_CRM_PRSegmentationClass.returnPicklistValuesDependOnRTidAndFieldName(
                prSegmentation.EUR_CRM_Business_Potential__r.RecordTypeId, 'EUR_CRM_Segmentation_BP_Aspect_Name__c'
            );
            this.potentialMap = EUR_CRM_PRSegmentationClass.returnPROFSPotentialMatrix(this.prSegmentation, this.brandBuildingPotentialLabels, this.businessPotentialLabels);

            noOfRow = this.brandBuildingPotentialLabels.size();
            noOfCol = this.businessPotentialLabels.size();
        }
        System.debug('\n imageLevelLabels => ' + JSON.serializePretty(imageLevelLabels) + '\n');
        System.debug('\n volumePotentialLabels => ' + JSON.serializePretty(volumePotentialLabels) + '\n');
        system.debug('initPotentials: PRS: ' + this.prSegmentation + ' potentialMap: ' + this.potentialMap);
    }

    /*************************************************************************************
    *   Initializes the answers of the of potentials
    *   Splits the answers by recordtype into their corrosponding lists
    *************************************************************************************/
    private void initAnswers() {
        prsBPUserAnswers = new List<EUR_CRM_PRS_Answer__c>();
        prsBBPUserAnswers = new List<EUR_CRM_PRS_Answer__c>();
        prsILUserAnswers = new List<EUR_CRM_PRS_Answer__c>();
        prsVPUserAnswers = new List<EUR_CRM_PRS_Answer__c>();

        // Loop through all answer records related to the PR Segmentation
        for(EUR_CRM_PRS_Answer__c criteria : prSegmentation.EUR_CRM_PRS_Answer__r){
            String recordType = criteria.Recordtype.DeveloperName;
            if(recordType == prsAnswerRecordTypeMap.get(BRAND_BUILDING_POTENTIAL)){
                prsBBPUserAnswers.add(criteria);
            }
            else if(recordtype == prsAnswerRecordTypeMap.get(BUSINESS_POTENTIAL)){
                prsBPUserAnswers.add(criteria);
            }
            else if(recordtype == prsAnswerRecordTypeMap.get(IMAGE_LEVEL)){
                prsILUserAnswers.add(criteria);
            }
            else if(recordtype == prsAnswerRecordTypeMap.get(VOLUME_POTENTIAL)){
                prsVPUserAnswers.add(criteria);
            }
        }
        System.debug('prsBPUserAnswers => ' + JSON.serializePretty(prsBPUserAnswers));
        System.debug('prsBBPUserAnswers => ' + JSON.serializePretty(prsBBPUserAnswers));
        System.debug('prsILUserAnswers => ' + JSON.serializePretty(prsILUserAnswers));
        System.debug('prsVPUserAnswers => ' + JSON.serializePretty(prsVPUserAnswers));
    }

    /************************************************************************************
    *   Sets the values of the button rendering variables for GroupOutletType, BBP and BP (for Profs), IL and VP (for Pros)
    *   Depends on whether the group outlet type is associated with BBP and BP questions
    *   and the total weight of the questions is 100.
    ************************************************************************************/
    private void validate() {
        Map<String, EUR_PROS_PROFS_Assignment__mdt> map_criterias = EUR_CRM_PRS_AspectAssignBasedOnCriteria.retrieveMetadata(
            this.prSegmentation.EUR_CRM_Account__r.RecordType.DeveloperName
        );
        
        // Group Outlet is always enabled
        isGroupDisabled = false;
        // The other two buttons are displayed only after a PRS Group Outlet Type has been chosen
        if(isPROFS){
            is_BBP_ButtonDisabled = true;
            is_BP_ButtonDisabled = true;
            if (this.groupOutletType.EUR_CRM_BrandBuildPotQuestionSet__c != null &&
                Double.valueOf(this.groupOutletType.EUR_CRM_BrandBuildPotQuestionSet__r.EUR_CRM_Total_Weight_of_All_Questions__c) == Double.valueOf(100))
            {
                is_BBP_ButtonDisabled = false;
            }
            if (this.groupOutletType.EUR_CRM_BusinessPotentialQuestionSet__c != null &&
                Double.valueOf(this.groupOutletType.EUR_CRM_BusinessPotentialQuestionSet__r.EUR_CRM_Total_Weight_of_All_Questions__c) == Double.valueOf(100))
            {
                is_BP_ButtonDisabled = false;
            }
            
            if(EUR_CRM_PRS_AspectAssignBasedOnCriteria.hasBBPLogic(map_criterias) == true) {
                is_BBP_ButtonDisabled = true;
            }
            if(EUR_CRM_PRS_AspectAssignBasedOnCriteria.hasBPLogic(map_criterias) == true) {
                is_BP_ButtonDisabled = true;
            }
        }
        else if(isPROS){
            is_IL_ButtonDisabled = true;
            is_VP_ButtonDisabled = true;
            if (this.groupOutletType.EUR_CRM_Image_Level_Question_Set__c != null &&
                Double.valueOf(this.groupOutletType.EUR_CRM_Image_Level_Question_Set__r.EUR_CRM_Total_Weight_of_All_Questions__c) == Double.valueOf(100) &&
                EUR_CRM_PRS_AspectAssignBasedOnCriteria.hasILLogic(map_criterias) == false)
            {
                is_IL_ButtonDisabled = false;
            }
            if (this.groupOutletType.EUR_CRM_Volume_Potential_Question_Set__c != null &&
                Double.valueOf(this.groupOutletType.EUR_CRM_Volume_Potential_Question_Set__r.EUR_CRM_Total_Weight_of_All_Questions__c) == Double.valueOf(100) &&
                EUR_CRM_PRS_AspectAssignBasedOnCriteria.hasVPLogic(map_criterias) == false)
            {
                is_VP_ButtonDisabled = false;
            }
        }
    }

    /*************************************************************************************
    *   Determines if the user is an admin of PRSegmentation
    *   Checks whether the user has the PRS_Admin permission set
    *   returns: Boolean, whether user has permission set or not
    **************************************************************************************/
    private Boolean determimeIsPRSAdmin() {
        List<PermissionSetAssignment> permSets = [SELECT PermissionSet.Id, PermissionSet.Name
        FROM PermissionSetAssignment
        WHERE Assignee.Username =: UserInfo.getUserName()
        ];
        if(permSets.size() > 0){
            for(PermissionSetAssignment permSet : permSets){
                if((permSet.PermissionSet.Name).contains('PROFS_Admin') || (permSet.PermissionSet.Name).contains('PRS_Admin') || (permSet.PermissionSet.Name).contains('PRS_Manager')){
                    return true;
                }
            }
        }
        return false;
    }

    /*************************************************************************************
    *   Determines whether the user has edit access to the PRSegmentation record
    *   Checks the UserRecordAccess object with the user ID, and the PRS record ID
    *   returns: Boolean, whether user has edit access or not
    *************************************************************************************/
    private Boolean determineEditAccess() {
        List<UserRecordAccess> userRecordAcess = [SELECT RecordId, HasEditAccess
        FROM UserRecordAccess
        WHERE UserId =: UserInfo.getUserId()
        AND RecordId =: this.prSegmentationId
        LIMIT 1
        ];
        if(userRecordAcess.size() > 0){
            if (userRecordAcess.get(0).HasEditAccess && Schema.sObjectType.EUR_CRM_PRS_Segmentation__c.isUpdateable()){
                return true;
            }
        }
        return false;
    }

    /**************************************************************************************
    *   Handlers to reroute to selection pages 
    *   EUR_CRM_PRS_GroupOutletSheet :  PRS Group Outlet Type
    *   EUR_CRM_PRS_QuestionsSheet   :  Both BBP, BP, IL, VP 
    *
    *   returns : PageReference to the new locations
    **************************************************************************************/
    public PageReference gotoGroupOutletTypeSheet() {
        pageReference pg = new pageReference('/apex/EUR_CRM_PRS_GroupOutletTypeSheet?id='+this.prSegmentationId);
        pg.setRedirect(true);
        return pg;
    }
    public PageReference gotoBBPSheet() {
        pageReference pg = new pageReference('/apex/EUR_CRM_PRS_QuestionsSheet?id='+this.prSegmentationId+'&type=1');
        pg.setRedirect(true);
        return pg;
    }
    public PageReference gotoBPSheet() {
        pageReference pg = new pageReference('/apex/EUR_CRM_PRS_QuestionsSheet?id='+this.prSegmentationId+'&type=2');
        pg.setRedirect(true);
        return pg;
    }
    public PageReference gotoILSheet() {
        pageReference pg = new pageReference('/apex/EUR_CRM_PRS_QuestionsSheet?id='+this.prSegmentationId+'&type=3');
        pg.setRedirect(true);
        return pg;
    }
    public PageReference gotoVPSheet() {
        pageReference pg = new pageReference('/apex/EUR_CRM_PRS_QuestionsSheet?id='+this.prSegmentationId+'&type=4');
        pg.setRedirect(true);
        return pg;
    }

}