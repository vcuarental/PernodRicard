/*
* Edit 11/26/14: Add validation on user's edit access
* Edit 12/10/14: For improvement deployment: commented out E1Flow  (PR_Group_Outlet_Type_Selection_E1)
* Edit 01/12/15: uncommented out E1Flow  (PR_Group_Outlet_Type_Selection_E1)
* Edit 02/02/15: For improvement deployment: commented out E1Flow  (PR_Group_Outlet_Type_Selection_E1)
* Edit 03/02/15: For KE and AO: added new recordtypes
* Edit 06/15/15: Added addtional condition: EUR_CRM_Active__c = true line 575
*/

public with sharing class EUR_CRM_ProsSegmentationExtCombined {
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
    public Boolean isPRT {get;set;}
    public Boolean isImageLevelRendered {get; set;}
    public Boolean isVolumePotentialRendered {get; set;}
    public Boolean isAccountPlanRendered {get;set;}
    public Boolean isNumberedAccountPlanRendered {get;set;}
    public Boolean isSetImageLevelRendered {get;set;}
    public Boolean isProsWeightRendered {get;set;}
    
    private EUR_CRM_Group_Outlet_Type__c groupOutletInfo{get;set;}
    
    public String decisionTree{get;set;}
    public String volumePotentialStatement{get;set;}{volumePotentialStatement = 'Potential Volume';}
    public Boolean isProsAdmin {get; set;}
    public Boolean hasEditAccess {get;set;} 
    
  //  public Flow.Interview.PR_Group_Outlet_Type_Selection_E1 E1Flow { get; set; }
    public Flow.Interview.PR_Group_Outlet_Type_Selection_NG_2 NG_Flow { get; set; }
    private EUR_CRM_Account__c  tempEuAccount;
    
    //Component Attribute
    public String accountId{get;set;}
    public String returnValue{get;set;}
    
    //Variables
    public EUR_CRM_ID_Card__c IdCard{get; set;}
    public Map <String, List <SelectOption>> mapCategorias{get;set;}{mapCategorias= new Map <String, List <SelectOption>>();}
    public List <String> listTabs{get;set;}
    //FROM CAP GEMINI: public List <perguntasWrapper> listPerguntasTab{get;set;}
    public Map <String, volumesWrapper> mapVolWrapper{get;set;}{mapVolWrapper= new Map <String, volumesWrapper>();}
    public Map <ID, EUR_CRM_Quality__c> mapMarcas{get;set;} 
    public Integer mapMarcasSize{set;}
    public Map <String, EUR_CRM_Category__c> mapCategory{get;set;}{mapCategory = new Map<String, EUR_CRM_Category__c>();}
    public String dialogTitle{get;set;}
    public String tab{get;set;}
    public Boolean modoDetail{get;set;}
    public Boolean hasIdCard{get;set;}
    
    public List <EUR_CRM_Quality__c> listMarcasSub = new List <EUR_CRM_Quality__c>();
    public Map <String, EUR_CRM_ID_Card_Volume__c> mapVolumes{get;set;} {mapVolumes=new Map <String, EUR_CRM_ID_Card_Volume__c>();}
    
    public String catId{get;set;}
    public String cat{get;set;}
    public String cla{get;set;}
    
    public boolean saveComplete{get;set;}{saveComplete=false;}
    
    public boolean displayPopup{get;set;}{displayPopup=false;}
    
    //Edit: (SFAPOR-15)
    public List<volumesWrapper> listVolWrapper{get{
        List<volumesWrapper> liVolWrapper = mapVolWrapper.values();
        liVolWrapper.sort();
        return liVolWrapper;
    }}

    public Set<Id> trackProductsToDelete = new Set<Id>();
    public List<EUR_CRM_PROS_Vol_Tracker_Product__c> listProsVolProds = new List<EUR_CRM_PROS_Vol_Tracker_Product__c>();
    public Map<String,List<EUR_CRM_PROS_Vol_Tracker_Product__c>> mapProsVolProds = new Map<String,List<EUR_CRM_PROS_Vol_Tracker_Product__c>>();
    public Map<String,List<EUR_CRM_PROS_Vol_Tracker_Product__c>> mapProsVolProdsDelete = new Map<String,List<EUR_CRM_PROS_Vol_Tracker_Product__c>>();
    public Boolean isNewCardVol = false;
    public Map<Id,String> mapBQSubCategory = new Map<Id,String>();

    public List<ProductWrapper> productTrackerWrapList {get;set;}
    
    //public boolean isPRT = true;
    
    public EUR_CRM_ProsSegmentationExtCombined(ApexPages.StandardController standardController)
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
        
        EUR_CRM_Pros_Segmentation__c prosSegmentation = (EUR_CRM_Pros_Segmentation__c)standardController.getRecord();
        
        if(prosSegmentation.EUR_CRM_Account__c != null){
            isPRT = false;
        }
        //accountId = prosSegmentation.EUR_CRM_Account__c;
        accountId = prosSegmentation.EUR_CRM_Standard_Account__c;
        returnValue = prosSegmentation.Id;
        
        System.debug('Flag - INIT VOLUME CARD 1:' + accountId + '|' + returnValue);
        mapBQSubCategory = new Map<Id,String>();

        initVolCard2();   
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
                            ORDER BY EUR_CRM_Criteria_Threshold__r.EUR_CRM_Sequence__c, EUR_CRM_Criteria_Threshold__r.EUR_CRM_Criteria_Order__c, EUR_CRM_Criteria_Threshold__r.CreatedDate];
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
    
    /**
    * Function: checkCountryCode
    * REFACTORED.
    * Additional affiliates now added in EUR_CRM_RecordTypeHelper class under getProsSegmentationExtCombined_RenderInfo
    * Initializes variables that will be used by the VF page to determine functionalities in the page
    **/
    private void checkCountryCode(){
        isPRT = false;

        if(this.prosSegmentation.EUR_CRM_Country_Code__c == 'PRT') {
            isPRT = true;
        }
        
        // Calls a function to determine whether Image level and volume potential button need to be shown in the page or not
        Map<String, Boolean> renderInformation = EUR_CRM_RecordTypeHelper.getProsSegmentationExtCombined_RenderInfo(
            this.prosSegmentation.EUR_CRM_Country_Code__c
        );
        
        if(renderInformation != null) {
            isImageLevelRendered = renderInformation.get('isImageLevelRendered');
            isVolumePotentialRendered = renderInformation.get('isVolumePotentialRendered');
            isAccountPlanRendered = renderInformation.get('isAccountPlanRendered');
            isNumberedAccountPlanRendered = renderInformation.get('isNumberedAccountPlanRendered');         
            isSetImageLevelRendered = renderInformation.get('isSetImageLevelRendered');
            isProsWeightRendered = renderInformation.get('isProsWeightRendered');
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
    
    public void initVolCard()
    {   if(isPRT){
        List <EUR_CRM_ID_Card__c> listIDCard = new List <EUR_CRM_ID_Card__c>([SELECT Id, Name, //EUR_CRM_Outlet_Type__c,
                                                                         EUR_CRM_Outlet__c, 
                                                                        EUR_CRM_Total_Super_Ultra_Brands__c
                                                                        //EUR_CRM_Total_Annual_Volume__c
                                                                        FROM EUR_CRM_ID_Card__c 
                                                                        WHERE EUR_CRM_Outlet__c =: accountId  
                                                                        LIMIT 1]);
        //FROM CAP GEMINI: listPerguntasTab = new List <perguntasWrapper>();
        System.debug('Flag - INIT VOLUME CARD 2:' + accountId + '|' + listIDCard);
        modoDetail = true;
        //System.debug('INIT EUR_CRM_IDCardSheetController: ' + listIDCard);
        
        if(listIDCard.size() == 0)
            criarIdCard();                
        else{
                IdCard = listIDCard[0];
                hasIdCard = true;
                System.debug('Flag ID CARD: ' + IdCard);
                getData(IdCard);
        }
    }
    }

    public void initVolCard2()
    {   if(isPRT){
        List <EUR_CRM_ID_Card__c> listIDCard = new List <EUR_CRM_ID_Card__c>([SELECT Id, Name, //EUR_CRM_Outlet_Type__c,
                                                                         EUR_CRM_Outlet__c, 
                                                                        EUR_CRM_Total_Super_Ultra_Brands__c
                                                                        //EUR_CRM_Total_Annual_Volume__c
                                                                        FROM EUR_CRM_ID_Card__c 
                                                                        WHERE EUR_CRM_Outlet__c =: accountId  
                                                                        LIMIT 1]);
        //FROM CAP GEMINI: listPerguntasTab = new List <perguntasWrapper>();
        System.debug('Flag - INIT VOLUME CARD 2:' + accountId + '|' + listIDCard);
        modoDetail = true;
        //System.debug('INIT EUR_CRM_IDCardSheetController: ' + listIDCard);
        
        if(listIDCard.size() == 0){}
            //criarIdCard();                
        else{
                IdCard = listIDCard[0];
                hasIdCard = true;
                System.debug('Flag ID CARD: ' + IdCard);
                getData(IdCard);
        }
    }
    }
    
    public void setAccountId(String account)
    {
       accountId = account;
    }
    
    public String getAccountId()
    {
       return accountId;
    }
    
    public Integer getMapMarcasSize(){
        if (mapMarcas== null)
            return 0;
        else
            return mapMarcas.size();
    }
    
    public void getData(EUR_CRM_ID_Card__c IdCard){
            // TABELA DE VOLUMES ---------------------------------------------------
            //Creates Category Map, and invokes initialization of Volume Wrapper Map
            System.debug('Flag On Get Data:' + IdCard);
            //Query às Famílias de Produtos
            mapCategorias = new Map <String, List <SelectOption>>();
            List <SelectOption> listOptions;
            listMarcasSub = ([SELECT id, Name, 
                            EUR_CRM_Brand__c, 
                            EUR_CRM_Sub_Category__c,
                            EUR_CRM_Brand__r.EUR_CRM_Category__r.Id,
                            EUR_CRM_Brand__r.EUR_CRM_Category__r.Name,
                            EUR_CRM_Brand__r.EUR_CRM_Category__r.EUR_CRM_Contributive_Margin__c,
                            EUR_CRM_Quality_Code__c , EUR_CRM_Quality_Is_Competitor__c,
                            EUR_CRM_House_Pour__c
                            FROM EUR_CRM_Quality__c
                            WHERE RecordType.Name LIKE 'EUR_PRT%'
                            AND EUR_CRM_House_Pour__c = true 
                            AND EUR_CRM_Active__c = true 
                            ORDER BY EUR_CRM_Quality_Is_Competitor__c, Name]);
             
             System.debug('flag - Brand Sub:' + listMarcasSub);
            
            //Criar Mapa com Categorias
            for(EUR_CRM_Quality__c mar : listMarcasSub){
                    if(mar.EUR_CRM_Brand__c == null){
                        listOptions = new List <SelectOption>();
                        listOptions.add(new SelectOption('','-None-'));
                        mapCategorias.put(mar.EUR_CRM_Brand__r.EUR_CRM_Category__r.Id, listOptions);
                    }
            }       
            
            //Adicionar listOptions de Marcas ao Mapa de Categorias
            for(EUR_CRM_Quality__c sub : listMarcasSub){
                    String key = sub.EUR_CRM_Brand__r.EUR_CRM_Category__r.Id;
                    if(sub.EUR_CRM_Brand__c != null){
                        listOptions = (mapCategorias.containsKey(key))?mapCategorias.get(key):new List <SelectOption>();
                        listOptions.add(new SelectOption(sub.id, sub.Name));
                        mapCategorias.put(key, listOptions);
                    }
            }
            
            getIDCardVolumes();
                                                                                                                    
    }

    public void getIdCardVolumes(){
        //Criar Mapa com Categorias a serem mostradas na tabela e valores
        //mapVolWrapper= new Map <String,volumesWrapper>();
        volumesWrapper volW;
        //EUR_CRM_ID_Card_Volume__c IDCardVol;
        // Query ID_Card_Volumes
        System.debug('Flag-getCardVolumes for ID Card: ' + IdCard);
        for(EUR_CRM_ID_Card_Volume__c idCardVolObj : [SELECT Id, EUR_CRM_ID_Card__c, Name, 
                                                       EUR_CRM_Category__c, 
                                                       EUR_CRM_Category__r.Name,
                                                       EUR_CRM_Category__r.EUR_CRM_Contributive_Margin__c,
                                                       EUR_CRM_Annual_Volume__c, 
                                                       EUR_CRM_Dose_Service__c, 
                                                       EUR_CRM_Service_Mark__c, 
                                                       EUR_CRM_No_Premium_Brands__c,
                                                       EUR_CRM_No_SuperPremium_Brands__c,
                                                       EUR_CRM_No_UltraPremium_Brands__c,
                                                       EUR_CRM_Service_Mark__r.EUR_CRM_Quality_Is_Competitor__c,
                                                       EUR_CRM_Service_Mark__r.Name
                                                       FROM EUR_CRM_ID_Card_Volume__c 
                                                       WHERE EUR_CRM_ID_Card__c =: IdCard.Id])
            {                                                                                                 
                mapVolumes.put(idCardVolObj.EUR_CRM_Category__c, idCardVolObj);
                
                volW = new volumesWrapper();
                        volW.vol_IDCardVolumes = idCardVolObj;
                        volW.vol_listMarcas = mapCategorias.get(idCardVolObj.EUR_CRM_Category__c);
                        volW.vol_nuSuperPrem = 0;
                        volW.categoryName = idCardVolObj.EUR_CRM_Category__r.Name;
                        volW.isCompetitor = idCardVolObj.EUR_CRM_Service_Mark__r.EUR_CRM_Quality_Is_Competitor__c;
                        volW.categoryContributiveMargin = (idCardVolObj.EUR_CRM_Category__r.EUR_CRM_Contributive_Margin__c==null)?0:idCardVolObj.EUR_CRM_Category__r.EUR_CRM_Contributive_Margin__c;
                        volW.bqName = idCardVolObj.EUR_CRM_Service_Mark__r.Name;
                        System.debug('########################################################LISTA1-ID CARD'+ volW.vol_IDCardVolumes);  
                        System.debug('########################################################LISTA1'+ volW.vol_listMarcas);     
                mapVolWrapper.put(idCardVolObj.EUR_CRM_Category__c, volW);                                                                                                  
        }
        
        //Adicionar Categorias
        for(EUR_CRM_Quality__c famObj : listMarcasSub){
                if (!(mapVolWrapper.containsKey(famObj.EUR_CRM_Brand__r.EUR_CRM_Category__r.Id))){
                    volW = new volumesWrapper();
                    EUR_CRM_ID_Card_Volume__c IDCardVol = new EUR_CRM_ID_Card_Volume__c(EUR_CRM_ID_Card__c = IdCard.id, 
                                                                EUR_CRM_Category__c = famObj.EUR_CRM_Brand__r.EUR_CRM_Category__r.Id,
                                                                EUR_CRM_Service_Mark__c = null,
                                                                EUR_CRM_No_Premium_Brands__c=0,
                                                                EUR_CRM_No_SuperPremium_Brands__c=0,
                                                                EUR_CRM_No_UltraPremium_Brands__c=0);        
                    volW.vol_IDCardVolumes = IDCardVol;
                    volW.categoryName = famObj.EUR_CRM_Brand__r.EUR_CRM_Category__r.Name;
                    volW.vol_listMarcas = mapCategorias.get(famObj.EUR_CRM_Brand__r.EUR_CRM_Category__r.Id);
                    volW.isCompetitor = famObj.EUR_CRM_Quality_Is_Competitor__c;
                    volW.categoryContributiveMargin = (famObj.EUR_CRM_Brand__r.EUR_CRM_Category__r.EUR_CRM_Contributive_Margin__c==null)?0:famObj.EUR_CRM_Brand__r.EUR_CRM_Category__r.EUR_CRM_Contributive_Margin__c;
                    volW.bqName = famObj.Name;
                    mapVolWrapper.put(famObj.EUR_CRM_Brand__r.EUR_CRM_Category__r.Id,volW);
                    mapVolumes.put(famObj.EUR_CRM_Brand__r.EUR_CRM_Category__r.Id, IDCardVol);
                    System.debug('########################################################LISTA2-ID CARD'+ volW.vol_IDCardVolumes); 
                    System.debug('########################################################LISTA2'+ volW.vol_listMarcas);     
                }
        }
        System.debug('Flag - Map Vol Wrapper: '+mapVolWrapper);
        System.debug('flag - Map categories: ' + mapCategorias);
    }

    //Abri caixa de diálogo
    public void getMarcasPremium(){
        System.debug('#########################ENTROU');
        System.debug('Flag - ID Card Volumes Map:' + mapVolumes);
        System.debug('Flag - ID:' + IdCard);
        catId = Apexpages.currentPage().getParameters().get('CategoriaId');
        cat = Apexpages.currentPage().getParameters().get('Categoria');
        cla = Apexpages.currentPage().getParameters().get('Classificacao');
        dialogTitle =  cat + ' - ' + cla; 
            
            //mapMarcas = new Map <ID, EUR_CRM_Quality__c>(); 
            mapMarcas = new Map<Id, EUR_CRM_Quality__c>([SELECT Id, Name,
                                    EUR_CRM_Brand__r.EUR_CRM_Category__r.Name,
                                    EUR_CRM_Brand__r.EUR_CRM_Category__c,
                                    EUR_CRM_Sub_Category__c,
                                    EUR_CRM_Brand__r.Id, EUR_CRM_Quality_Is_Competitor__c,
                                    EUR_CRM_House_Pour__c 
                                    FROM EUR_CRM_Quality__c
                                    WHERE EUR_CRM_Sub_Category__c=:cla
                                    AND EUR_CRM_House_Pour__c = true
                                    AND EUR_CRM_Brand__r.EUR_CRM_Category__c=:catId]);

            System.debug('Quality Map - Sub Category:' + mapMarcas);   

        Set<Id> bQProductIds = new Set<Id>();
        if(IdCard != null){
            for(EUR_CRM_PROS_Vol_Tracker_Product__c trackProd : [SELECT Id, EUR_CRM_Brand_Quality__c, EUR_CRM_ID_Card_Volume__c FROM EUR_CRM_PROS_Vol_Tracker_Product__c WHERE EUR_CRM_ID_Card_Volume__r.EUR_CRM_ID_Card__c =:IdCard.Id]){
                bQProductIds.add(trackProd.EUR_CRM_Brand_Quality__c);
            }
        }
        
        System.debug('$$CATID: '+catId);
        System.debug('$$CAT: '+cat);
        System.debug('$$cla: '+cla);
        System.debug('$$BQPRODUCTS: '+bQProductIds);
        productTrackerWrapList = new List<ProductWrapper>();
        for(EUR_CRM_Quality__c bQuality : mapMarcas.values()){
            Boolean isProduct = false;
            if(bQProductIds.contains(bQuality.Id)){
                isProduct = true;
            }
            productTrackerWrapList.add(new ProductWrapper(isProduct, bQuality));
            mapBQSubCategory.put(bQuality.Id, bQuality.EUR_CRM_Sub_Category__c);
        }

        System.debug('##TEST WRAPPER: '+productTrackerWrapList);
        

    }
    
            // Salvar marcas
    public PageReference saveMarcasPremium(){
        PageReference pageRef = null;
        System.Savepoint pSavepoint = Database.setSavepoint();
        try {
                System.debug('#################################'+cat);
                System.debug('Flag - On Save Marcas Map Volumes:' + mapVolumes +'#####'+ mapVolumes.containsKey(catId)); 
                System.debug('Flag - On Save Categorias Map Volumes:' + mapCategorias + '####'+ IdCard);
                if (IdCard==null){
                    System.debug('Flag - ID Card is null, reset');
                    initVolCard();
                }
                System.debug('Flag - SaveMarcasPremium Checker:' + IdCard + '|' + catId);
                String sss = Apexpages.currentPage().getParameters().get('Str');
                String sssRemove = Apexpages.currentPage().getParameters().get('Str2');
       
            List <ID> listMarcasChecked = new List <ID>();
            if(sss!=null && sss.length()>0){
                    sss = sss.removeEnd(',');
                    
                    if (sss.contains(','))
                            listMarcasChecked = sss.split(',');
                else
                    listMarcasChecked.add(sss);
             }

            List <ID> listMarcasUnChecked = new List <ID>();
            if(sssRemove!=null && sssRemove.length()>0){
                    sssRemove = sssRemove.removeEnd(',');
                    
                    if (sssRemove.contains(','))
                            listMarcasUnChecked = sssRemove.split(',');
                else
                    listMarcasUnChecked.add(sssRemove);
             }

            EUR_CRM_ID_Card_Volume__c IDCardV;
            if(mapVolumes.containsKey(catId)){
                    IDCardV = mapVolumes.get(catId);
                    System.debug('Flag IDCardV 1:' +  IDCardV);
            }
            else{
                    IDCardV = new EUR_CRM_ID_Card_Volume__c(EUR_CRM_ID_Card__c = IdCard.id, 
                                                                                            EUR_CRM_Category__c = catId,
                                                        EUR_CRM_No_Premium_Brands__c=0,
                                                        EUR_CRM_No_SuperPremium_Brands__c=0,
                                                        EUR_CRM_No_UltraPremium_Brands__c=0);
                    System.debug('Flag IDCardV 2:' +  IDCardV);
            }
            
            //System.debug('IDCardV: ' + IDCardV);
            IDCardV.EUR_CRM_No_Premium_Brands__c = (IDCardV.EUR_CRM_No_Premium_Brands__c==null)?0:IDCardV.EUR_CRM_No_Premium_Brands__c;
            IDCardV.EUR_CRM_No_SuperPremium_Brands__c = (IDCardV.EUR_CRM_No_SuperPremium_Brands__c==null)?0:IDCardV.EUR_CRM_No_SuperPremium_Brands__c;
            IDCardV.EUR_CRM_No_UltraPremium_Brands__c = (IDCardV.EUR_CRM_No_UltraPremium_Brands__c==null)?0:IDCardV.EUR_CRM_No_UltraPremium_Brands__c;
            
            System.debug('IDCardV: ' + IDCardV);
            
            if (cla.equalsIgnoreCase('Premium'))
            {IDCardV.EUR_CRM_No_Premium_Brands__c = listMarcasChecked.size();}
            else if (cla.equalsIgnoreCase('Super Premium'))
            {IDCardV.EUR_CRM_No_SuperPremium_Brands__c = listMarcasChecked.size();}
            else if (cla.equalsIgnoreCase('Ultra Premium'))
            {IDCardV.EUR_CRM_No_UltraPremium_Brands__c = listMarcasChecked.size();}
            
            //System.debug('Flag - Upsert ID Card Volume:' + IDCardV);       
            //Database.upsert(IDCardV);
            
            //pageRef = new PageReference('/'+ ApexPages.currentPage().getParameters().get('id') );
            //pageRef.setRedirect(true);

            System.debug('$$VOL PROS: '+listMarcasChecked);
            //Create PROS Vol Tracker Product
            String keyString = IDCardV.Id+':'+cla+';'+catId;
            System.debug('$$KEY STRING: '+keyString);
            Integer ctr = 0;
            if(IDCardV.Id == null){
                isNewCardVol = true;
            }
            for(Id key : listMarcasChecked){

                EUR_CRM_PROS_Vol_Tracker_Product__c prosVolProd = new EUR_CRM_PROS_Vol_Tracker_Product__c();
                prosvolProd.EUR_CRM_Brand_Quality__c = key;
                prosvolProd.EUR_CRM_ID_Card_Volume__c = IDCardV.Id;

                //listProsVolProds.add(prosvolProd);
                if (mapProsVolProds.containsKey(keyString)){
                    if(ctr == 0){
                        mapProsVolProds.get(keyString).clear();
                    }
                    mapProsVolProds.get(keyString).add(prosvolProd);
                } else {
                    mapProsVolProds.put(keyString, new  List<EUR_CRM_PROS_Vol_Tracker_Product__c> {prosvolProd});
                }
                ctr++;
            }
            //System.debug('$$VOL PROS PRODUCTS: '+listProsVolProds);
            System.debug('$$VOL PROS PRODUCTS: '+mapProsVolProds);

            for(Id key : listMarcasUnChecked){

                EUR_CRM_PROS_Vol_Tracker_Product__c prosVolProd = new EUR_CRM_PROS_Vol_Tracker_Product__c();
                prosvolProd.EUR_CRM_Brand_Quality__c = key;
                prosvolProd.EUR_CRM_ID_Card_Volume__c = IDCardV.Id;

                //listProsVolProds.add(prosvolProd);
                if (mapProsVolProdsDelete.containsKey(keyString)){
                    if(ctr == 0){
                        mapProsVolProdsDelete.get(keyString).clear();
                    }
                    mapProsVolProdsDelete.get(keyString).add(prosvolProd);
                } else {
                    mapProsVolProdsDelete.put(keyString, new  List<EUR_CRM_PROS_Vol_Tracker_Product__c> {prosvolProd});
                }
                ctr++;
            }
            //System.debug('$$VOL PROS PRODUCTS: '+listProsVolProds);
            System.debug('$$VOL PROS PRODUCTS DELETE: '+mapProsVolProdsDelete);

            System.debug('Flag - On Save Marcas ID Card Volume:' + IDCardV);
        }
        catch(Exception e){
            System.debug('Upsert Error: ' + e);
            pageRef= null;
                    Database.rollback(pSavepoint);      
            String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
            if(e.getTypeName() == 'DMLException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION) 
            {
                String s = e.getDmlMessage(0);
                strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());    
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strError));
            }                   
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
        }
            
        return pageRef;               
    }
    
    // SALVAR ID CARD-----------------------------------------
    public PageReference saveP(){
        //Salvar Volumes
        System.debug('Flag - On SaveP');
        PageReference pageRef= null;
        System.Savepoint pSavepoint = Database.setSavepoint();

        try{
            List <EUR_CRM_ID_Card_Volume__c> listInsertVol = new List <EUR_CRM_ID_Card_Volume__c>();
            
            if (mapVolWrapper == null){
                    System.debug('Flag - Map Volume Wrapper is null, reset it');
                    initVolCard();
            }
            
            System.debug('Flag - OnSaveP mapVolumeWrapper:' + mapVolWrapper);
            for(volumesWrapper volW : mapVolWrapper.values())
            {       
                EUR_CRM_ID_Card_Volume__c IDVol = volW.vol_IDCardVolumes;
                //if(IDVol.EUR_CRM_Service_Mark__c != null || IDVol.EUR_CRM_Dose_Service__c != null || IDVol.EUR_CRM_Annual_Volume__c != null){               
                listInsertVol.add(IDVol);               
                //}
            }
            
            System.debug('Flag - On SaveP Upsert ID Card Volumes: ' + listInsertVol);
            upsert listInsertVol;

            Map<Id, Id> cardVolumeMap = new Map<Id, Id>();
            for(EUR_CRM_ID_Card_Volume__c cardVol : listInsertVol){
                cardVolumeMap.put(cardVol.EUR_CRM_Category__c, cardVol.Id);
            }
            System.debug('Flag - On SaveP MAP CARDVOL ' + cardVolumeMap);
            //DELETE UNCHECKED
            System.debug('%%SAVE2: ' + mapProsVolProdsDelete);
            if(mapProsVolProdsDelete.size() > 0){
                List<EUR_CRM_PROS_Vol_Tracker_Product__c> deleteTrackProductsUncheck = new List<EUR_CRM_PROS_Vol_Tracker_Product__c>();
                Set<Id> idCardVolumes = new Set<Id>();
                Set<Id> brandQualityDel = new Set<Id>();
                Set<String> subCategDel = new Set<String>();
                for(String key : mapProsVolProdsDelete.keyset()){
                     for(EUR_CRM_PROS_Vol_Tracker_Product__c trackProd : mapProsVolProdsDelete.get(key)){
                        if(trackProd.EUR_CRM_ID_Card_Volume__c != null){
                            idCardVolumes.add(trackProd.EUR_CRM_ID_Card_Volume__c);
                            brandQualityDel.add(trackProd.EUR_CRM_Brand_Quality__c);
                        }
                    }
                }
                if(idCardVolumes.size()>0){
                    for(EUR_CRM_PROS_Vol_Tracker_Product__c delTrack : [SELECT Id FROM EUR_CRM_PROS_Vol_Tracker_Product__c WHERE EUR_CRM_ID_Card_Volume__c IN: idCardVolumes AND EUR_CRM_Brand_Quality__c IN :brandQualityDel]){
                        deleteTrackProductsUncheck.add(delTrack);
                    }

                    System.debug('&&DELTRACKUNCHECKED: '+deleteTrackProductsUncheck);
                    if(deleteTrackProductsUncheck.size() > 0){
                        delete deleteTrackProductsUncheck;
                    }
                }

            }
            //INSERT Pros Vol Tracker Products
            System.debug('%%SAVE: ' + mapProsVolProds);
            if(mapProsVolProds.size() > 0){
                List<EUR_CRM_PROS_Vol_Tracker_Product__c> insertTrackProducts = new List<EUR_CRM_PROS_Vol_Tracker_Product__c>();
                List<EUR_CRM_PROS_Vol_Tracker_Product__c> deleteTrackProducts = new List<EUR_CRM_PROS_Vol_Tracker_Product__c>();
                Set<String> subCateg = new Set<String>();
                for(String key : mapProsVolProds.keyset()){
                    for(EUR_CRM_PROS_Vol_Tracker_Product__c trackProd : mapProsVolProds.get(key)){
                        if(trackProd.EUR_CRM_ID_Card_Volume__c == null){
                            String volCardId = key.substringAfter(';');
                            if(cardVolumeMap.containskey(volCardId)){
                                trackProd.EUR_CRM_ID_Card_Volume__c = cardVolumeMap.get(volCardId);
                            }  
                        }
                        insertTrackProducts.add(trackProd);
                        trackProductsToDelete.add(trackProd.EUR_CRM_ID_Card_Volume__c);
                        if(mapBQSubCategory.containskey(trackProd.EUR_CRM_Brand_Quality__c)){
                            subCateg.add(mapBQSubCategory.get(trackProd.EUR_CRM_Brand_Quality__c));
                        }
                        //subCateg.add(trackProd.EUR_CRM_Sub_Category__c);
                        System.debug('**BQ: '+trackProd.EUR_CRM_Brand_Quality__c+' : '+trackProd.EUR_CRM_Sub_Category__c);
                    }
                }

                System.debug('%%TRACKTODELETE: ' + trackProductsToDelete);
                System.debug('%%subCateg: ' + subCateg);
                if(trackProductsToDelete.size()>0){
                    for(EUR_CRM_PROS_Vol_Tracker_Product__c delTrack : [SELECT Id FROM EUR_CRM_PROS_Vol_Tracker_Product__c WHERE EUR_CRM_ID_Card_Volume__c IN: trackProductsToDelete AND EUR_CRM_Sub_Category__c IN :subCateg]){
                        deleteTrackProducts.add(delTrack);
                    }

                    System.debug('&&DELTRACK: '+deleteTrackProducts);
                    if(deleteTrackProducts.size() > 0){
                        delete deleteTrackProducts;
                    }
                }

                upsert insertTrackProducts;
            }

            //Go to Pros Segmentation
            pageRef = new PageReference('/'+ ApexPages.currentPage().getParameters().get('id') );
            pageRef.setRedirect(true);
        }
        catch(Exception e){
            System.debug('Upsert Error: ' + e);
            pageRef = null;
            Database.rollback(pSavepoint);      
                    String strError = e.getMessage() +'|'+ String.valueOf(e.getLineNumber());
                if(e.getTypeName() == 'DMLException' && e.getDmlType(0) == System.Statuscode.FIELD_CUSTOM_VALIDATION_EXCEPTION) 
                {
                    String s = e.getDmlMessage(0);
                    strError += strError.substring(strError.indexOf(':') + ':'.length(), strError.length());    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, strError));
                }                   
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, strError));
        }
        
        System.debug('FLAG On SaveP - Page Reference:' + pageRef);
        return pageRef;
    }
    
    public void criarIdCard(){
        //EUR_CRM_ID_Card__c IdCardSheetNew = createNewIdCardSheet();
        System.debug('Flag - Create new ID Card');
        EUR_CRM_ID_Card__c IdCardNew = new EUR_CRM_ID_Card__c(EUR_CRM_Outlet__c = accountId);  
        insert IdCardNew;
        hasIDCard = true;
        IDCard = IdCardNew;
        getData(IDCard);
    }

    public class ProductWrapper{

        public Boolean isChecked {get;set;}
        public EUR_CRM_Quality__c brandQuality {get;set;}
        
        public ProductWrapper(Boolean isChecked, EUR_CRM_Quality__c brandQuality){
            this.isChecked = isChecked;
            this.brandQuality = brandQuality;
        }
    }


    public class volumesWrapper implements Comparable {
        public ID vol_IDCardVolume{get; set;}
        public EUR_CRM_ID_Card_Volume__c vol_IDCardVolumes{get; set;}
        public String vol_Categoria{get; set;}
        public Integer vol_volumesAnuais{get; set;}
        public Integer vol_doseServico{get; set;}
        public String vol_marcaServico{get; set;}
        public Integer vol_nuPrem{get{return vol_nuPrem == null?0:vol_nuPrem;} set;}
        public Integer vol_nuSuperPrem{get{return vol_nuSuperPrem == null?0:vol_nuSuperPrem;} set;}
        public Integer vol_nuUltraPrem{get{return vol_nuUltraPrem == null?0:vol_nuUltraPrem;} set;}
        public List <SelectOption> vol_listMarcas{get; set;}     
        public String categoryName{get;set;} 
        //Edit:(SFAPOR-15)
        public String bqName{get;set;}
        public Boolean isCompetitor {get;set;}
        public Decimal categoryContributiveMargin{get;set;} 


        
        public Integer compareTo(Object compareTo){
            volumesWrapper compareToVolumesWrapper = (volumesWrapper) compareTo;
            if (categoryContributiveMargin>compareToVolumesWrapper.categoryContributiveMargin){return -1;}
            else if(categoryContributiveMargin==compareToVolumesWrapper.categoryContributiveMargin){
                if(categoryName==compareToVolumesWrapper.categoryName){return 0;}
                else if(categoryName>compareToVolumesWrapper.categoryName){return 1;}
                return -1;
            }
            return 1;
        }
    }
}