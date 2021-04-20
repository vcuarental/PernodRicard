public without sharing class ASI_CRM_MY_AccountProsSegController {
    
    private ApexPages.StandardController standardController;
    private User activeUser{get; set;}
    //private Boolean hasActiveAffiliate {get;set;}{false;}
    
    public ASI_CRM_Pros_Segmentation__c prosSegmentation{get;set;}
    
    public Boolean isDisplayed{get; set;}{isDisplayed = false;}  
    public boolean isRedirect {get;set;}{isRedirect = false;}
    public string url {get;set;}
    
    public Id servicePackId{get;set;}{servicePackId=null;}
    public String groupOutletType {set; get;}
    public String channelType {set; get;}
    public String subChannelType {set; get;}
    public String outletType {set; get;}
    public String imageLevel {set; get;}
    public String volumePotential {set; get;}
    
    public List<String> imageLevelLabels{get;set;}
    public List<String> volumePotentialLabels{get;set;}
    public Map<String, Boolean> imageVolumeMap{get;set;}
    
    //DAMD Matrix
    public Map<String, String> damdmatrixMap {get;set;}
    public List<String> marketShareLabels{get;set;}
    
    public Boolean isOfftrade {get;set;}{isOfftrade = false;}
    
    public static Set<String> DEFAULT_IMAGE_LEVELS = new Set<String>{'Iconic','Leading','Premium','Mainstream'};
    private List<ASI_CRM_AccountsAdditionalField__c> ASAccountList = new List<ASI_CRM_AccountsAdditionalField__c>();
        public ASI_CRM_MY_AccountProsSegController(ApexPages.StandardController standardController)
        {
                Boolean isCreatePage = true;
                this.standardController = standardController;
                //Get Active User
                String userId = UserInfo.getUserId();
                System.debug('Flag - UserId: ' + userId);
                this.activeUser = [SELECT CompanyName, Country FROM User WHERE Id=:userId LIMIT 1];
                String accId = standardController.getId();
            	// ASI_CRM_AccountsAdditionalField__c acc = (ASI_CRM_AccountsAdditionalField__c)standardController.getRecord();
            	// System.debug('acc: ' + acc);
                // system.debug('accId ' + accId );
                // Retrieve Pros Segmentation
                getProsSeg();
                
                ASAccountList = [Select Id,RecordType.Name from ASI_CRM_AccountsAdditionalField__c where Id =:accId];
                
                if (ASAccountList == null || ASAccountList.size() == 0 ){
                    if (prosSegmentation == null){
                        isCreatePage = false;
                    }else{
                        servicePackId = prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c;
                        if (servicePackId==null){
                             //servicePackId = ASI_CRM_SG_ProsSegmentationClass.returnServicePackId(prosSegmentation);
                        }
                    }
                }
                else if (ASAccountList.size() > 0){
                    if (prosSegmentation == null){
                        //this.addPageMessage('Please contact your System Administrator. No Pros Segmentation Exist.', ApexPages.Severity.INFO);
                        isCreatePage = false;
                    }else{
                         servicePackId = prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c;
                         if (servicePackId==null){
                             //servicePackId = ASI_CRM_SG_ProsSegmentationClass.returnServicePackId(prosSegmentation);
                         }
                    }
                    /* commented out 3/5/2015
                    if(ASAccountList[0].ASI_CRM_SG_force_iconic_account__c){
                     //     commented out 10/8/2014
                     //    this.addPageMessage('PROS Segmentation of this account is forced to be Iconic', ApexPages.Severity.WARNING);
                    }
                    */
                }
                isDisplayed = true;
                if (isCreatePage){
                   // system.debug('!!! Test Country Code: ' + prosSegmentation.ASI_CRM_SG_Country_Code__c);
                    
                    //isDisplayed = true;
                    createPage();
                    initImageVolumeFieldSet();
                }
                
        }
    
    public ASI_CRM_Pros_Segmentation__c getProsSeg(){
        Id accountId = this.standardController.getId();
        
        prosSegmentation = null;
        //Baltics - modified query to reference Image Level and Potential Volume lookup name value
        List<ASI_CRM_Pros_Segmentation__c> tempPros = [SELECT Id, ASI_CRM_SG_Account__r.Id,ASI_CRM_SG_Customer__r.Id,
                                                        ASI_CRM_SG_Group_Outlet_Type__c, ASI_CRM_SG_Outlet_Type__c,
                                                        ASI_CRM_SG_Image_Level__c, ASI_CRM_SG_Volume_Potential__c,
                                                        ASI_CRM_SG_Service_Pack__c,
                                                        ASI_CRM_SG_Is_Image_Level_Modified__c, ASI_CRM_SG_Is_Volume_Potential_Modified__c,
                                                        ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Name__c,
                                                        ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c,
                                                        ASI_CRM_SG_Outlet_Type__r.ASI_CRM_SG_Name__c, 
                                                        ASI_CRM_SG_Image_Level__r.ASI_CRM_SG_Name__c, ASI_CRM_SG_Volume_Potential__r.ASI_CRM_SG_Name__c,
                                                        ASI_CRM_SG_Image_Level_Threshold__c, ASI_CRM_SG_Volume_Potential_Threshold__c,
                                                        ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c, 
                                                        ASI_CRM_SG_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c,
                                                        ASI_CRM_SG_Image_Level_Id__c,
                                                        ASI_CRM_SG_Volume_Potential_Id__c,
                                                       	Channel__r.Name,
                                                       	ASI_CRM_Visit_Frequency_Thresholds__r.ASI_CRM_Visit_Frequency__c,
                                                       	ASI_CRM_SG_DAMD_Threshold__r.ASI_CRM_Visit_Duration__c,
                                                       	ASI_CRM_Investment_Guidelines_Thresholds__r.ASI_CRM_Recommended_CM__c,
                                                       	Sub_Channel__r.Name,
                                                       	Region__c,
                            							ASI_CRM_OP__c 
                                                        FROM ASI_CRM_Pros_Segmentation__c
                                                        WHERE ASI_CRM_SG_Customer__c =: accountId 
                                                        LIMIT 1];
        
        
        
        
        system.debug('@@@PROS@@@: '+tempPros);
        if(!tempPros.isEmpty()){
            for(ASI_CRM_Pros_Segmentation__c pros : tempPros){
                prosSegmentation = pros;
                if(prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c != null && prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c == 'Offtrade') isOfftrade = true;
            }
                // prosSegmentation = tempPros[0];
                // if(prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c != null && prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c == 'Offtrade') isOfftrade = true; 
        }
        system.debug('prosSegmentation: '+prosSegmentation);
        return prosSegmentation;
    }
    
    public void initImageVolumeFieldSet(){
                
                this.imageVolumeMap = new Map<String, Boolean>();
                this.imageLevelLabels = new List<String>();
                this.volumePotentialLabels = new List<String>();
                
                
                List<Schema.PicklistEntry> imageLabels = returnImageLevels();
                //imageLevelLabels = imageLabels;
                List<Schema.PicklistEntry> volumeLabels = returnVolumePotentials();
                //volumePotentialLabels = volumeLabels;
                
                for(Schema.PicklistEntry vol: volumeLabels){
                        //volumePotentialLabels.add(new FieldVal(vol.getValue()));
                        volumePotentialLabels.add(vol.getValue());
                } 
                //Baltics - modified condition to avoid null values on map
                //02/11/14 - Modified condition(referenced jucntion objs Image Level and Vol Potential Thresholds)
                
                for (Schema.PicklistEntry image: imageLabels){
                        for(Schema.PicklistEntry vol: volumeLabels){
                            system.debug('%%Imagegetvalue::' + image.getValue());
                            system.debug('%%Volumegetvalue::' + vol.getValue());
                            system.debug('%%IMG::' + this.prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c);
                            system.debug('%%VOLPOT::' + this.prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c);
                            if(this.prosSegmentation!= null && image.getValue().equalsIgnoreCase(this.prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c) && 
                            vol.getValue().equalsIgnoreCase(this.prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c)){
                                    imageVolumeMap.put(image.getValue()+vol.getValue(), true);
                            }else{
                            imageVolumeMap.put(image.getValue()+vol.getValue(), false);
                            }
                         }
                        //imageLevelLabels.add(new FieldVal(image.getValue()));
                        imageLevelLabels.add(image.getValue());
                        
                        system.debug('###imageVolumeMap' + imageVolumeMap + '');
                        system.debug('###image' + image );
                }
                
                /* commented out 3/5/2015
                if(ASAccountList != null && ASAccountList.size() > 0 && ASAccountList[0].ASI_CRM_SG_Force_Iconic_Account__c){
                    String imageName = prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c;
                    String volumePotentialName = prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c;
                    
                    String iconicImage = 'Iconic';
                    
                    system.debug('!!!  ' + imageName  +volumePotentialName  );
                    imageVolumeMap.put(imageName+volumePotentialName, false);
                    imageVolumeMap.put(iconicImage +volumePotentialName, true);
                }
                */
                
                this.marketShareLabels = returnMarketShareLabels();
                if(prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c != null && prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c != null){
                    //Get Id Card
                    ASI_CRM_ID_Card__c IdCard = [SELECT Id, Name, ASI_CRM_SG_Outlet__c, 
                                                ASI_CRM_SG_Total_Super_Ultra_Brands__c,
                                                ASI_CRM_SG_Total_Annual_Volume__c,
                                                ASI_CRM_SG_Outlet__r.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c
                                                FROM ASI_CRM_ID_Card__c 
                                                WHERE ASI_CRM_SG_Outlet__c =: prosSegmentation.ASI_CRM_SG_Customer__c LIMIT 1];
                    if(IdCard != null){
                        this.damdmatrixMap = retrieveDAMDMatrix(IdCard, prosSegmentation);
                    }
                }
        }
        
        public List<Schema.PicklistEntry> returnImageLevels()
        {
                Schema.DescribeFieldResult fieldResult = ASI_CRM_Image_Level__c.ASI_CRM_SG_Name__c.getDescribe();
                System.debug('Describe Field: ' + fieldResult);
                //List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                List<Schema.PicklistEntry> ple = new List<Schema.PicklistEntry>();
                
                for(Schema.PicklistEntry tempPle : fieldResult.getPicklistValues()){
                    String val = tempPle.getValue();
                    if(DEFAULT_IMAGE_LEVELS.contains(val)){
                            ple.add(tempPle);
                    }
                }
                return ple;
        }
        
        public List<Schema.PicklistEntry> returnVolumePotentials()
        {
                Schema.DescribeFieldResult fieldResult = ASI_CRM_Volume_Potential__c.ASI_CRM_SG_Name__c.getDescribe();
                System.debug('Describe Field: ' + fieldResult);
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
                return ple;
        }
    
    public void createPage(){
        //prosSegmentation = getProsSeg();
        
        if (prosSegmentation != null){
                
                //Baltics - changed text to lookup fields
                groupOutletType = prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c;
            	channelType = prosSegmentation.Channel__r.Name;
            	subChannelType = prosSegmentation.Sub_Channel__r.Name;
                outletType = prosSegmentation.ASI_CRM_SG_Outlet_Type__r.ASI_CRM_SG_Name__c;
                imageLevel = prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c;
                volumePotential = prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__r.ASI_CRM_SG_Volume_Potential_Name__c;
        }
    }
        
        public Component.Apex.CommandButton getCustomLink(){
                Component.Apex.CommandButton customLink  = new Component.Apex.CommandButton();
                
                if (prosSegmentation != null){
                        //Apex.Component.OutputLink content = new Apex.Component.OutputLink();
                        customLink.value = 'Open Pros Segmentation';
                        customLink.expressions.action = '{!openProsSeg}';
                }
                else{
                        customLink.value = 'Create Pros Segmentation';
                        customLink.expressions.action = '{!createProsSegmentation}';
                }
                customLink.rerender = new Set<String>{'redirectPanel'};
                return customLink;
        }
        
        public PageReference createProsSegmentation(){
                
                ASI_CRM_Pros_Segmentation__c newProsSegmentation = null;
                try{
                    	ASI_CRM_AccountsAdditionalField__c acc = [SELECT OwnerId 
                                                                  FROM ASI_CRM_AccountsAdditionalField__c 
                                                                  WHERE Id = :this.standardController.getId()];
                        newProsSegmentation = new ASI_CRM_Pros_Segmentation__c();
                        newProsSegmentation.ASI_CRM_SG_Customer__c = this.standardController.getId();
                    	newProsSegmentation.OwnerId = acc.OwnerId;
                    	newProsSegmentation.recordtypeid = Global_RecordTypeCache.getRTId('ASI_CRM_Pros_Segmentation__cASI_CRM_MY_PROS_Segmentation');
                        Database.insert(newProsSegmentation);
                    
           
                }
                catch(Exception e){
                        System.debug('Insert Error: ' + e.getMessage());
                } 
                
                if (newProsSegmentation != null){                       
                        url = '/apex/ASI_CRM_MY_ProsSegmentationPage?id=' + newProsSegmentation.Id;
                        System.debug('Flag - redirect url:' + url);      
                        isRedirect = true;
                }
                return null;
        }
        
        
        
    public PageReference openProsSeg() {
        if (prosSegmentation!=null){    
            url = '/apex/ASI_CRM_MY_ProsSegmentationPage?id=' + prosSegmentation.Id;
            System.debug('Flag - redirect url:' + url);         
            isRedirect = true;
        }
        return null;
    }

        public PageReference openAccountPlan(){
                url = '/apex/ASI_CRM_MY_AccountPlan?id='+this.prosSegmentation.Id;
        System.debug('Flag - redirect url:' + url);         
        isRedirect = true;
        return null;
                
    }
    
    
        public void addPageMessage(String strMessage, ApexPages.Severity severity)
    {
        ApexPages.Message infoMessage = new ApexPages.Message(severity, strMessage);
        ApexPages.addMessage(infoMessage);      
    }
    
    public static List<String> returnMarketShareLabels()
    {
        List<String> msLabels = new List<String>();
        Schema.DescribeFieldResult fieldResult = ASI_CRM_DAMD_Threshold__c.ASI_CRM_SG_Market_Share__c.getDescribe();
        System.debug('Describe Field: ' + fieldResult);
        List<Schema.PicklistEntry> values = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry ms: values){
                msLabels.add(ms.getValue());
        }
        return msLabels;
    }
    
    public static Map<String, String> retrieveDAMDMatrix(ASI_CRM_ID_Card__c IdCard, ASI_CRM_Pros_Segmentation__c prosSegmentation){
              
        List<String> volLabels = new List<String>();        
                
                Schema.DescribeFieldResult fieldResult = ASI_CRM_Volume_Potential__c.ASI_CRM_SG_Name__c.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
                for(Schema.PicklistEntry vol: ple){
                        volLabels.add(vol.getValue());
                }
                 
        List<String> msLabels = returnMarketShareLabels();
        Map<String, String> damdmatrixMap = new Map<String, String>();
        Decimal allNonPRSAnnualVol = 0;
        Decimal allPRSAnnualVol = 0;
        Decimal nonPRSGorssSale = 0;
        Decimal PRSGorssSale = 0;
        Decimal total = 0;
        Decimal mshare = 0;
                                            
        //Compute Annual Vol and Annual Vol of PR Brands                                    
        for(ASI_CRM_ID_Card_Volume__c idCardVol : [SELECT Id, ASI_CRM_SG_ID_Card__c, Name, 
                                                       ASI_CRM_SG_Annual_Volume__c, ASI_CRM_SG_Dose_Service__c, 
                                                       ASI_CRM_SG_Service_Mark__c, ASI_CRM_SG_No_Premium_Brands__c,
                                                       ASI_CRM_SG_No_SuperPremium_Brands__c, ASI_CRM_SG_No_UltraPremium_Brands__c,
                                                       ASI_CRM_SG_Service_Mark__r.ASI_CRM_SG_Quality_Is_Competitor__c,
                                                       ASI_CRM_SG_Service_Mark__r.Name,
                                                   	   ASI_CRM_SG_Service_Mark__r.ASI_CRM_MY_Price__c,
                                                       ASI_CRM_SG_Annual_Volume_Index_X__c
                                                       FROM ASI_CRM_ID_Card_Volume__c 
                                                       WHERE ASI_CRM_SG_ID_Card__c =: IdCard.Id]){
            
                Decimal gorssSale = idCardVol.ASI_CRM_SG_Service_Mark__r.ASI_CRM_MY_Price__c != null ? idCardVol.ASI_CRM_SG_Service_Mark__r.ASI_CRM_MY_Price__c : 0;
                Decimal annual_volume = idCardVol.ASI_CRM_SG_Annual_Volume__c != null ? idCardVol.ASI_CRM_SG_Annual_Volume__c : 0;                                          
                if(idCardVol.ASI_CRM_SG_Service_Mark__r.ASI_CRM_SG_Quality_Is_Competitor__c){
                    allNonPRSAnnualVol = allNonPRSAnnualVol + annual_volume;
                    nonPRSGorssSale = nonPRSGorssSale + (gorssSale * annual_volume);
                    
                }
                else{
                    
                    allPRSAnnualVol = allPRSAnnualVol + annual_volume;
                    PRSGorssSale = PRSGorssSale + (gorssSale * annual_volume);
                }
            
        }
        
        Decimal prs = allNonPRSAnnualVol + allPRSAnnualVol; //IdCard.ASI_CRM_SG_Total_Annual_Volume__c
        if(allPRSAnnualVol > 0 && prs > 0){
            mshare = (allPRSAnnualVol/prs).setscale(2);
        }
        else if(allPRSAnnualVol > 0 && allNonPRSAnnualVol <= 0){
            mshare = 1;
        }
        
        
        String outletType = IdCard.ASI_CRM_SG_Outlet__r.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c;
        
        system.debug('Market SHARE ##: '+ mshare);
        system.debug('Annual NON PRS Volume ' + allNonPRSAnnualVol + ' Annual PRS Volume ' + allPRSAnnualVol);     
        system.debug('TEEEST '+ IdCard.ASI_CRM_SG_Outlet__r.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c);
        
		List<ASI_CRM_DAMD_Threshold__c> damdList = 
            [SELECT Id, 
             ASI_CRM_SG_Min_Weight__c, 
             ASI_CRM_SG_Action__c, 
             ASI_CRM_SG_Market_Share__c,
             ASI_CRM_SG_Volume_Potential__c, 
             ASI_CRM_SG_Volume_Potential_Name__c 
            FROM ASI_CRM_DAMD_Threshold__c 
            WHERE ASI_CRM_MY_Outlet_Prioritization__c =: prosSegmentation.ASI_CRM_OP__c
            ORDER BY ASI_CRM_SG_Min_Weight__c DESC];
        
        system.debug('damdList: '+damdList);        
		Id vpId = [SELECT ASI_CRM_SG_Volume_Potential__r.Id 
                   FROM ASI_CRM_Volume_Potential_Threshold__c 
                   WHERE Id =: prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c 
                   LIMIT 1].ASI_CRM_SG_Volume_Potential__r.Id;   
        
        for(ASI_CRM_DAMD_Threshold__c damd : damdList){
            damdmatrixMap.put(damd.ASI_CRM_SG_Market_Share__c+damd.ASI_CRM_SG_Volume_Potential_Name__c, '--');
        }
     
        
        for(ASI_CRM_DAMD_Threshold__c damd : damdList){
            system.debug('mini ' + mshare + ' > '+ damd.ASI_CRM_SG_Min_Weight__c);
            
            if(mshare >= damd.ASI_CRM_SG_Min_Weight__c && vpId == damd.ASI_CRM_SG_Volume_Potential__c){        
                damdmatrixMap.put(damd.ASI_CRM_SG_Market_Share__c+damd.ASI_CRM_SG_Volume_Potential_Name__c, damd.ASI_CRM_SG_Action__c);
                break;
            }
        }
        
        return damdmatrixMap;
    }
    
}