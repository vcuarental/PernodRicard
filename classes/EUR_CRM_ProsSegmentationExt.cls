/*
* Edit 11/26/14: Add validation on user's edit access
* Edit 12/10/14: For improvement deployment: commented out E1Flow  (PR_Group_Outlet_Type_Selection_E1)
* Edit 01/12/15: uncommented out E1Flow  (PR_Group_Outlet_Type_Selection_E1)
* Edit 02/02/15: For improvement deployment: commented out E1Flow  (PR_Group_Outlet_Type_Selection_E1)
* Edit 03/02/15: For KE and AO: added new recordtypes
*/

public with sharing class EUR_CRM_ProsSegmentationExt {
    private ApexPages.StandardController standardController;
    private EUR_CRM_ProsSegmentationManager prosMgr {get;set;}

    public EUR_CRM_Pros_Segmentation__c prosSegmentation{get;set;}
    public List<String> imageLevelLabels{get;set;}
    public List<String> volumePotentialLabels{get;set;}
    public Map<String, Boolean> imageVolumeMap{get;set;}

    public List<EUR_CRM_Pros_Image_Level__c> prosImageLevel;
    public List<EUR_CRM_Pros_Volume_Potential__c> prosVolumePotential;
    public Id servicePackId;

    public Id prosSegmentationId{get;set;}

    public List<SelectOption> outletTypeOptions;
    public String selectedOutlet{set; get;}
    public Boolean displayOutletType {get;set;}

    public Boolean isGroupDisabled{get;set;}
    public Boolean isOutletDisabled{get;set;}
    public Boolean isImageDisabled{get;set;}{isImageDisabled=true;}
    public Boolean isVolumeDisabled{get;set;}{isVolumeDisabled=true;}
    public Boolean isVolumeDisabled2{get;set;}{isVolumeDisabled2=true;}
    public Boolean isVolumeCardAvailable;
    public Boolean isFlowRendered {get; set;}
    public String flowCode {get;set;}
    public String countryName {get;set;}

    private EUR_CRM_Group_Outlet_Type__c groupOutletInfo{get;set;}

    public String decisionTree{get;set;}
    public String volumePotentialStatement{get;set;}{volumePotentialStatement = 'Potential Volume';}
    public Boolean isProsAdmin {get; set;}
    public Boolean hasEditAccess {get;set;}

    //  public Flow.Interview.PR_Group_Outlet_Type_Selection_E1 E1Flow { get; set; }
    public Flow.Interview.PR_Group_Outlet_Type_Selection_NG_2 NG_Flow { get; set; }
    private EUR_CRM_Account__c  tempEuAccount;

    public EUR_CRM_ProsSegmentationExt(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
        prosMgr = new EUR_CRM_ProsSegmentationManager();

        this.prosSegmentationId = this.standardController.getId();

        if(this.prosSegmentationId!=null)  {
            returnProsSegmentation();

            System.debug('Flag - Pros Segmentation Details:' + prosSegmentation + '|' + prosSegmentation.EUR_CRM_Account__c);
            returnDecisionTree();
            validate();
            checkCountryCode();
            determimeProsAdmin();
            hasEditAccess = determineEditAccess(prosSegmentation.Id);
            if(prosSegmentation.EUR_CRM_Account__c != null)
                tempEuAccount = [Select Id, eur_crm_force_iconic_account__c from EUR_CRM_Account__c where Id =:prosSegmentation.EUR_CRM_Account__c];
            if(tempEuAccount != null && tempEuAccount.eur_crm_force_iconic_account__c ){
                // commented out 10/8/2014
                //   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'PROS Segmentation of this account is forced to be Iconic'));
            }
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.EUR_CRM_ProsNotExist));
        }
    }

    public void returnProsSegmentation(){
        prosSegmentation = EUR_CRM_ProsSegmentationClass.returnProsSegmentationviaId(this.standardController.getId());
    }

    public PageReference initProsSegmentationObj(){
        initSummary();
        returnProsSegmentation();

        return null;
    }

    public String returnDecisionTree()
    {
        //decisionTree = prosSegmentation.EUR_CRM_Affiliate__r.EUR_CRM_Decision_Tree__c;
        //Baltics - reference to Pros Seg obj
        decisionTree = prosSegmentation.EUR_CRM_Decision_Tree__c;
        return decisionTree;
    }

    public Boolean getIsVolumeCardAvailable(){
        Boolean hasVolumeCard = false;

        if(prosSegmentation!=null){
            EUR_CRM_ProsSegmentationFactory.IProsSegmentationInterface instance = prosMgr.newClassInstance(prosSegmentation.RecordTypeId);
            hasVolumeCard = (instance!=null)?instance.hasVolumeCard():false;
        }
        System.debug('IS VOL CARD AVAILABLE:' + hasVolumeCard);
        return hasVolumeCard;
    }

    public void setProsImageLevel(List<EUR_CRM_Pros_Image_Level__c> prosImageLevel)
    {
        this.prosImageLevel = prosImageLevel;
    }

    public void setProsVolumePotential(List<EUR_CRM_Pros_Volume_Potential__c> prosVolumePotential)
    {
        this.prosVolumePotential = prosVolumePotential;
    }

    public List<EUR_CRM_Pros_Image_Level__c> getProsImageLevel()
    {
        this.prosImageLevel = [SELECT Id,
            EUR_CRM_Criteria_Threshold__r.EUR_CRM_Question__c,
            EUR_CRM_Answer__c,
            EUR_CRM_Weight__c
        //,EUR_CRM_Is_Mass_Update__c
        FROM EUR_CRM_Pros_Image_Level__c
        WHERE EUR_CRM_Pros_Segmentation__c =: this.prosSegmentation.Id
            AND EUR_CRM_Criteria_Threshold__r.Id != null
        //AND EUR_CRM_Is_Mass_Update__c = true
        ORDER BY EUR_CRM_Criteria_Threshold__r.EUR_CRM_Criteria_Order__c, EUR_CRM_Criteria_Threshold__r.CreatedDate];
        //ORDER BY EUR_CRM_Criteria_Threshold__r.Id];
        return this.prosImageLevel;
    }

    public List<EUR_CRM_Pros_Volume_Potential__c> getProsVolumePotential()
    {
        this.prosVolumePotential = [SELECT Id,
            EUR_CRM_Criteria_Threshold__r.EUR_CRM_Question__c,
            EUR_CRM_Answer__c,
            EUR_CRM_Weight__c //,EUR_CRM_Is_Mass_Update__c
        FROM EUR_CRM_Pros_Volume_Potential__c
        WHERE EUR_CRM_Pros_Segmentation__c =: this.prosSegmentation.Id
            AND EUR_CRM_Criteria_Threshold__r.Id != null
            //AND EUR_CRM_Is_Mass_Update__c = true
        ];
        return this.prosVolumePotential;
    }

    public void setOutletTypeOptions(List<SelectOption> outletTypeOptions)
    {
        this.outletTypeOptions = outletTypeOptions;
    }

    public List<SelectOption> getOutletTypeOptions()
    {
        outletTypeOptions = new List<SelectOption>();
        List<EUR_CRM_Outlet_Type__c> outletTypes = [SELECT Id, EUR_CRM_Name__c
        FROM EUR_CRM_Outlet_Type__c
        WHERE EUR_CRM_Group_Outlet_Type__c IN
        (SELECT Id FROM EUR_CRM_Group_Outlet_Type__c
        WHERE EUR_CRM_Affiliate__c=:this.prosSegmentation.EUR_CRM_Affiliate__c
            AND EUR_CRM_Name__c=:prosSegmentation.EUR_CRM_Group_Outlet_Type__c)
        LIMIT 4999];
        if (outletTypes.size()>0){
            for(EUR_CRM_Outlet_Type__c outlet: outletTypes){
                outletTypeOptions.add(new SelectOption(outlet.EUR_CRM_Name__c, outlet.EUR_CRM_Name__c));
            }

            if(prosSegmentation.EUR_CRM_Outlet_Type__c != null)
                selectedOutlet = prosSegmentation.EUR_CRM_Outlet_Type__c;
        }

        System.debug('Outlets:' + outletTypeOptions);
        return outletTypeOptions;
    }

    public void setServicePackId(Id servicePackId){
        this.servicePackId = servicePackId;
    }

    public Id getServicePackId(){
        servicePackId = EUR_CRM_ProsSegmentationClass.returnServicePackId(this.prosSegmentation);
        //if(servicePackId!=null){
        prosSegmentation.EUR_CRM_Service_Pack__c = servicePackId;
        //}

        return servicePackId;
    }

    public Component.Apex.OutputPanel getCustomForm()
    {
        return null;
    }

    public void initSummary(){
        initImageVolumeFieldSet();
    }

    public void initImageVolumeFieldSet(){
        String countrCode = this.prosSegmentation.EUR_CRM_Country_Code__c;
        this.imageLevelLabels = EUR_CRM_ProsSegmentationClass.returnImageLevelLabels(countrCode );
        //this.imageLevelLabels = EUR_CRM_ProsSegmentationClass.returnImageLevelLabels();
        this.volumePotentialLabels = EUR_CRM_ProsSegmentationClass.returnVolumePotentialLabels();
        this.imageVolumeMap = EUR_CRM_ProsSegmentationClass.returnImageVolumeMatrix(this.prosSegmentation);
        system.debug('!!! initimagevolumefields pros : ' + this.prosSegmentation + ' imageVolumeMap: ' + this.imageVolumeMap);
        if(tempEuAccount != null && tempEuAccount.EUR_CRM_Force_Iconic_Account__c){
            String imageName = prosSegmentation.EUR_CRM_Image_Level_Threshold__r.EUR_CRM_Image_Level_Name__c;
            String volumePotentialName = prosSegmentation.EUR_CRM_Volume_Potential_Threshold__r.EUR_CRM_Volume_Potential_Name__c;

            String iconicImage = 'Iconic';

            system.debug('!!!  ' + imageName  +volumePotentialName  );
            imageVolumeMap.put(imageName+volumePotentialName, false);
            imageVolumeMap.put(iconicImage +volumePotentialName, true);
        }
    }

    public EUR_CRM_Group_Outlet_Type__c returnGroupOutlet(){
        groupOutletInfo = new EUR_CRM_Group_Outlet_Type__c();
        //Baltics 2 - Modified query to reference lookup field GroupOutletName and country code for for country specific
        List<EUR_CRM_Group_Outlet_Type__c> tempGroupOutlet = [SELECT Id, EUR_CRM_Name__c,EUR_CRM_Group_Outlet_Name__c,
            EUR_CRM_Image_Criteria_Set__c,
            EUR_CRM_Image_Criteria_Set__r.EUR_CRM_Total_Criteria_Weight__c,
            EUR_CRM_Volume_Criteria_Set__c,
            EUR_CRM_Volume_Criteria_Set__r.EUR_CRM_Total_Criteria_Weight__c,
            EUR_CRM_Outlet_Type_Count__c,
            EUR_CRM_Country_Code__c
        FROM EUR_CRM_Group_Outlet_Type__c
        WHERE EUR_CRM_Group_Outlet_Name__c  =: this.prosSegmentation.EUR_CRM_Group_Outlet_Type__r.EUR_CRM_Group_Outlet_Name__c
            AND EUR_CRM_Country_Code__c =: this.prosSegmentation.EUR_CRM_Country_Code__c LIMIT 1];
        //WHERE EUR_CRM_Name__c =: this.prosSegmentation.EUR_CRM_Group_Outlet_Type__c
        //AND EUR_CRM_Affiliate__c =: this.prosSegmentation.EUR_CRM_Affiliate__c
        //LIMIT 1];

        if (tempGroupOutlet.size()>0){
            groupOutletInfo = tempGroupOutlet[0];
        }
        system.debug('groupOutletInfo :::' + groupOutletInfo);
        return groupOutletInfo;
    }

    public PageReference processGroupOutletType(){
        if(this.prosSegmentation != null && this.prosSegmentation.eur_crm_country_code__c == 'AT'){
            pageReference pg = new pageReference('/apex/EUR_CRM_AssignGroupOutletTypePage?id='+this.prosSegmentation.Id);
            pg.setRedirect(true);
            return pg;
        }else{
            pageReference pg = new pageReference('/apex/'+this.decisionTree+'?id='+this.prosSegmentation.Id);
            pg.setRedirect(true);
            return pg;
        }
    }

    public PageReference processImageLevel(){
        pageReference pg = new pageReference('/apex/EUR_CRM_CriteriaSheet?id='+this.prosSegmentation.Id+'&type=1');
        pg.setRedirect(true);
        return pg;
    }

    public PageReference processVolumePotential(){
        pageReference pg = new pageReference('/apex/EUR_CRM_CriteriaSheet?id='+this.prosSegmentation.Id+'&type=2');
        pg.setRedirect(true);
        return pg;
    }

    public PageReference processAccountPlan(){
        pageReference pg = new pageReference('/apex/EUR_CRM_AccountPlan?id='+this.prosSegmentation.Id);
        pg.setRedirect(true);
        return pg;
    }

    private void validate()
    {
        isGroupDisabled = true;
        isOutletDisabled = true;
        isImageDisabled = true;
        isVolumeDisabled = true;
        isVolumeDisabled2 = true;
        //validate Group Outlet Type Button
        //System.debug('FLAG - Affiliate Decision Tree:'+this.prosSegmentation.EUR_CRM_Affiliate__r.EUR_CRM_Decision_Tree__c);
        //if(this.prosSegmentation.EUR_CRM_Affiliate__r.EUR_CRM_Decision_Tree__c!=null){
        if(this.prosSegmentation.EUR_CRM_Decision_Tree__c!=null){ //Baltics - used Decision Tree in Pros Seg 
            isGroupDisabled = false;
        }

        //Validate Outlety Type
        System.debug('FLAG - Pros Seg:'+this.prosSegmentation.EUR_CRM_Group_Outlet_Type__c);
        System.debug('Flag - Pros Segmentation Record Type:' + prosSegmentation.RecordTypeId +' - '+prosMgr.newClassInstance(prosSegmentation.RecordTypeId));
        if(this.prosSegmentation.EUR_CRM_Group_Outlet_Type__c!=null){
            returnGroupOutlet();
            system.debug('rtID::' + prosSegmentation.RecordTypeId);
            System.debug('FLAG - Total Image Criteria:' + groupOutletInfo.EUR_CRM_Volume_Criteria_Set__r.EUR_CRM_Total_Criteria_Weight__c);
            system.debug('CONDI1' + (groupOutletInfo.EUR_CRM_Volume_Criteria_Set__c != null));
            system.debug('CONDI2' + prosSegmentation.RecordTypeId);
            system.debug('CONDI4' + Double.valueOf(groupOutletInfo.EUR_CRM_Volume_Criteria_Set__r.EUR_CRM_Total_Criteria_Weight__c));
            system.debug('VALIDATE VOL CARD:'+(groupOutletInfo.EUR_CRM_Volume_Criteria_Set__c != null)+'--'+(prosSegmentation.RecordTypeId != null)+'--'+(Double.valueOf(groupOutletInfo.EUR_CRM_Volume_Criteria_Set__r.EUR_CRM_Total_Criteria_Weight__c)==Double.valueOf(100)));


            if (groupOutletInfo.EUR_CRM_Image_Criteria_Set__c != null && Double.valueOf(groupOutletInfo.EUR_CRM_Image_Criteria_Set__r.EUR_CRM_Total_Criteria_Weight__c)==Double.valueOf(100))
            {isImageDisabled = false;}
            if (groupOutletInfo.EUR_CRM_Volume_Criteria_Set__c != null &&(prosMgr.newClassInstance(prosSegmentation.RecordTypeId)!= null && !prosMgr.newClassInstance(prosSegmentation.RecordTypeId).hasVolumeCard())&& Double.valueOf(groupOutletInfo.EUR_CRM_Volume_Criteria_Set__r.EUR_CRM_Total_Criteria_Weight__c)==Double.valueOf(100))
            {isVolumeDisabled = false;}
            if (groupOutletInfo.EUR_CRM_Volume_Criteria_Set__c != null && prosSegmentation.RecordTypeId != null && Double.valueOf(groupOutletInfo.EUR_CRM_Volume_Criteria_Set__r.EUR_CRM_Total_Criteria_Weight__c)==Double.valueOf(100))
            {isVolumeDisabled2 = false;}
            if (groupOutletInfo.EUR_CRM_Outlet_Type_Count__c != null && groupOutletInfo.EUR_CRM_Outlet_Type_Count__c>0)
            {isOutletDisabled = false;}
        }
    }

    private void checkCountryCode(){
        String countryCode = this.prosSegmentation.EUR_CRM_Country_Code__c;
        System.debug('PROS_SEGMENTATION---> ' + this.prosSegmentation);

        Map<String, Object> flowInformation = EUR_CRM_RecordTypeHelper.getProsSegmentationExt_FlowInfo(countryCode);

        if(flowInformation != null) {
            System.debug('FLOW INFORMATIONS-------> ' + flowInformation);
            String bool = (String) flowInformation.get('isFlowRendered');
            if (bool == 'true') {
                isFlowRendered = true;
            }else{
                isFlowRendered = false;
            }

            flowCode = countryCode;
            countryName = (String) flowInformation.get('countryName');
        }
    }

    private void determimeProsAdmin(){
        isProsAdmin = false;
        List<PermissionSetAssignment> permSets = [SELECT PermissionSet.Id,PermissionSet.Name
        FROM PermissionSetAssignment
        WHERE Assignee.Username =:UserInfo.getUserName()];
        if(permSets != null && permSets.size() >0 ){
            for(PermissionSetAssignment permSet: permSets){
                if((permSet.PermissionSet.Name).contains('PROS_Admin')){
                    isProsAdmin = true;
                }
            }
        }
    }

    private Boolean determineEditAccess(Id prosId){
        Boolean isProsEditable = false;
        List<UserRecordAccess> userRecordAcess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId=:UserInfo.getUserId() AND RecordId=:prosId LIMIT 1];
        if(userRecordAcess.size()>0){
            if (userRecordAcess.get(0).HasEditAccess && Schema.sObjectType.EUR_CRM_Pros_Segmentation__c.isUpdateable()){
                return true;
            }
        }
        return isProsEditable;
    }
}