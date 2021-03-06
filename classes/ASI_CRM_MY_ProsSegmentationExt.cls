public without sharing class ASI_CRM_MY_ProsSegmentationExt {

    //Settings
    public Boolean isGroupDisabled{get;set;}
    public Boolean isOwnerDisabled{get;set;}
    public Boolean isImageDisabled{get;set;}{isImageDisabled=true;}
    public Boolean isVolumeDisabled{get;set;}{isVolumeDisabled=true;}
    public Boolean isProsAdmin {get; set;}
    public Boolean isVolumeCardAvailable {get{return true;}}
    public Boolean isOfftrade{get;set;}{isOfftrade=false;}
    public Boolean isServicePackDisabled{get;set;}{isServicePackDisabled=true;}
    private Id currentUserId = UserInfo.getUserId();
    Set<Id> s_visiableUserIds = new Set<Id>();
        
    
    //Pros Variables
    public ASI_CRM_Pros_Segmentation__c prosSegmentation{get;set;}
    public List<String> imageLevelLabels{get;set;}
    public List<String> volumePotentialLabels{get;set;}
    public Map<String, Boolean> imageVolumeMap{get;set;}
    public List<ASI_CRM_Pros_Image_Level__c> prosImageLevel{set; 
        get{
            return [SELECT Id, 
                    ASI_CRM_SG_Criteria_Threshold__r.ASI_CRM_SG_Question__c,
                    ASI_CRM_SG_Answer__c,
                    ASI_CRM_SG_Weight__c
                    //,ASI_CRM_Is_Mass_Update__c
                    FROM ASI_CRM_Pros_Image_Level__c 
                    WHERE ASI_CRM_SG_Pros_Segmentation__c =: this.prosSegmentation.Id
                    AND ASI_CRM_SG_Criteria_Threshold__r.Id != null
                    //AND ASI_CRM_Is_Mass_Update__c = true
                    ORDER BY ASI_CRM_SG_Criteria_Threshold__r.ASI_CRM_SG_Criteria_Order__c, ASI_CRM_SG_Criteria_Threshold__r.CreatedDate];
                    //ORDER BY ASI_CRM_Criteria_Threshold__r.Id]; 
            //return this.prosImageLevel;
        }
    }
    public List<ASI_CRM_Pros_Volume_Potential__c> prosVolumePotential{set; 
        get{
            return [SELECT Id, 
                    ASI_CRM_SG_Criteria_Threshold__r.ASI_CRM_SG_Question__c,
                    ASI_CRM_SG_Answer__c,
                    ASI_CRM_SG_Weight__c //,ASI_CRM_Is_Mass_Update__c
                    FROM ASI_CRM_Pros_Volume_Potential__c
                    WHERE ASI_CRM_SG_Pros_Segmentation__c =: this.prosSegmentation.Id
                    AND ASI_CRM_SG_Criteria_Threshold__r.Id != null
                    //AND ASI_CRM_Is_Mass_Update__c = true
                    ]; 
            //return this.prosVolumePotential;
        }
    }
    public Id servicePackId {set;
        get{
            Id svcPackId = ASI_CRM_MY_ProsSegmentationClass.returnServicePackId(this.prosSegmentation);
            prosSegmentation.ASI_CRM_SG_Service_Pack__c = svcPackId;
            return svcPackId;
        }
    }
    
    public List<ASI_CRM_Pros_Image_Level__c> getProsImageLevel(){
        return prosImageLevel;
    }
    
    public List<ASI_CRM_Pros_Volume_Potential__c> getProsVolumePotential(){
        return prosVolumePotential;
    }
    
    //Market Share Variables
    public Map<String, String> damdmatrixMap {get;set;}
    public List<String> marketShareLabels{get;set;}
    
    //Volume Card Variables
    
    //Local
    private ApexPages.StandardController standardController;
    private ASI_CRM_Group_Outlet_Type__c groupOutletInfo{get;set;}

    public ASI_CRM_MY_ProsSegmentationExt(ApexPages.StandardController standardController)
    {
        this.standardController = standardController;
        if(this.standardController.getId()!=null)  {  
            prosSegmentation = ASI_CRM_MY_ProsSegmentationClass.returnProsSegmentationviaId(this.standardController.getId());
            System.debug('Flag - Pros Segmentation Details:' + prosSegmentation + '|' + prosSegmentation.ASI_CRM_SG_Customer__c );  
            List<User> l_availableUsers =[SELECT Id, ManagerId FROM User WHERE ManagerId =: currentUserId OR Id = :currentUserId ];
            for(User u: l_availableUsers){
                s_visiableUserIds.add(u.Id);
            }
            validate();
            determimeProsAdmin();
        }
        else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.ASI_CRM_ProsNotExist));
        }    

    }
    
    public void initSummary(){
        this.imageLevelLabels = ASI_CRM_MY_ProsSegmentationClass.returnImageLevelLabels();
        this.volumePotentialLabels = ASI_CRM_MY_ProsSegmentationClass.returnVolumePotentialLabels();
        this.imageVolumeMap = ASI_CRM_MY_ProsSegmentationClass.returnImageVolumeMatrix(this.prosSegmentation);
        system.debug('!!! initimagevolumefields pros : ' + this.prosSegmentation + ' imageVolumeMap: ' + this.imageVolumeMap);

        system.debug('!!Image Id :'+ prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c + ' !!Volume Id : ' +prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c);
        this.marketShareLabels = ASI_CRM_MY_ProsSegmentationClass.returnMarketShareLabels();
        if(prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c != null && prosSegmentation.ASI_CRM_SG_Volume_Potential_Threshold__c != null){
            //Get Id Card
            ASI_CRM_ID_Card__c IdCard = [SELECT Id, Name, ASI_CRM_SG_Outlet__c, 
                                        ASI_CRM_SG_Total_Super_Ultra_Brands__c,
                                        ASI_CRM_SG_Total_Annual_Volume__c, 
                                        ASI_CRM_SG_Outlet__r.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c
                                        FROM ASI_CRM_ID_Card__c 
                                        WHERE ASI_CRM_SG_Outlet__c =: prosSegmentation.ASI_CRM_SG_Customer__c LIMIT 1];
            if(IdCard != null){
               damdmatrixMap = ASI_CRM_MY_ProsSegmentationClass.retrieveDAMDMatrix(IdCard, prosSegmentation);
            }
       }
    }
    
    public PageReference processGroupOutletType(){
        pageReference pg = new pageReference('/apex/ASI_CRM_MY_ChannelTypePage?id='+this.prosSegmentation.Id);
        pg.setRedirect(false);
        return pg;      
    }
    
    public PageReference processImageLevel(){
            pageReference pg = new pageReference('/apex/ASI_CRM_MY_CriteriaSheet?id='+this.prosSegmentation.Id+'&type=1');
            pg.setRedirect(true);
            return pg;
    }
    
    public PageReference processVolumeCard(){
            pageReference pg = new pageReference('/apex/ASI_CRM_MY_VolumeCard?id='+this.prosSegmentation.Id);
            pg.setRedirect(true);
            return pg;
    }
    
    public PageReference processVolumePotential(){
        pageReference pg = new pageReference('/apex/ASI_CRM_CriteriaSheet?id='+this.prosSegmentation.Id+'&type=2');
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference processAccountPlan(){
                pageReference pg = new pageReference('/apex/ASI_CRM_MY_AccountPlan?id='+this.prosSegmentation.Id);
        pg.setRedirect(true);
        return pg;
    }
    
    public PageReference processResetImageLevel(){
            pageReference pg = new pageReference('/apex/ASI_CRM_MY_Reset_Image_Level?id='+this.prosSegmentation.Id+'&type=1');
            pg.setRedirect(true);
            return pg;
    }
    
    private void validate()
    {
        isGroupDisabled = false;
        isImageDisabled = true;
        isVolumeDisabled = true;
        isOwnerDisabled = true;
        
        system.debug('@@@currentUserId: '+currentUserId);
        system.debug('@@@prosSegmentation.OwnerId: '+this.prosSegmentation.OwnerId);
        if(s_visiableUserIds.contains(this.prosSegmentation.ASI_CRM_SG_Customer__r.OwnerId)){
            isOwnerDisabled = false;
        }
        else{
            isOwnerDisabled = true;
        }
        
        //Validate Outlet Type
        System.debug('FLAG - Pros Seg:'+this.prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c);
        System.debug('Flag - Pros Segmentation Record Type:' + prosSegmentation.RecordTypeId +' - ');
        if(this.prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c!=null){
            returnGroupOutlet();
            system.debug('rtID::' + prosSegmentation.RecordTypeId);
            System.debug('FLAG - Total Image Criteria:' + groupOutletInfo.ASI_CRM_SG_Volume_Criteria_Set__r.ASI_CRM_SG_Total_Criteria_Weight__c);
            system.debug('CONDI1' + (groupOutletInfo.ASI_CRM_SG_Volume_Criteria_Set__c != null));
            system.debug('CONDI2' + prosSegmentation.RecordTypeId);
            system.debug('CONDI4' + Double.valueOf(groupOutletInfo.ASI_CRM_SG_Volume_Criteria_Set__r.ASI_CRM_SG_Total_Criteria_Weight__c));
            system.debug('VALIDATE VOL CARD:'+(groupOutletInfo.ASI_CRM_SG_Volume_Criteria_Set__c != null)+'--'+(prosSegmentation.RecordTypeId != null)+'--'+(Double.valueOf(groupOutletInfo.ASI_CRM_SG_Volume_Criteria_Set__r.ASI_CRM_SG_Total_Criteria_Weight__c)==Double.valueOf(100)));
            
            
            if (groupOutletInfo.ASI_CRM_SG_Image_Criteria_Set__c != null && Double.valueOf(groupOutletInfo.ASI_CRM_SG_Image_Criteria_Set__r.ASI_CRM_SG_Total_Criteria_Weight__c)==Double.valueOf(100))
            {isImageDisabled = false;}
            if (groupOutletInfo.ASI_CRM_SG_Volume_Criteria_Set__c != null && prosSegmentation.ASI_CRM_SG_Image_Level__c != null && prosSegmentation.RecordTypeId != null && Double.valueOf(groupOutletInfo.ASI_CRM_SG_Volume_Criteria_Set__r.ASI_CRM_SG_Total_Criteria_Weight__c)==Double.valueOf(100))
            {isVolumeDisabled = false;}
            if(groupOutletInfo != null && prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__r.Name.contains('Offtrade'))
            {isOfftrade = true;}
            if(prosSegmentation.ASI_CRM_Investment_Guidelines_Thresholds__c  != null){
                isServicePackDisabled = false;
            }
            
            //isImageDisabled = false;
            //isVolumeDisabled = false;
            //isOfftrade = false;
            
            system.debug('groupOutletInfo : '+groupOutletInfo);
            system.debug('isImageDisabled : '+isImageDisabled);
            system.debug('isVolumeDisabled : '+isVolumeDisabled);
            system.debug('isOfftrade : '+isOfftrade);
        }
        
    }

    private ASI_CRM_Group_Outlet_Type__c returnGroupOutlet(){
        groupOutletInfo = new ASI_CRM_Group_Outlet_Type__c();
        //String region = 'Central';
        List<ASI_CRM_Group_Outlet_Type__c> tempGroupOutlet = 
                [SELECT Id, ASI_CRM_SG_Name__c,ASI_CRM_SG_Group_Outlet_Name__c,
                ASI_CRM_SG_Image_Criteria_Set__c, 
                ASI_CRM_SG_Image_Criteria_Set__r.ASI_CRM_SG_Total_Criteria_Weight__c,
                ASI_CRM_SG_Volume_Criteria_Set__c,
                ASI_CRM_SG_Volume_Criteria_Set__r.ASI_CRM_SG_Total_Criteria_Weight__c,
                ASI_CRM_SG_Outlet_Type_Count__c
                FROM ASI_CRM_Group_Outlet_Type__c
                /* Patched by Vincent Lam 20160317
                 * Why don't check ID? Name will be duplicated.
                 */
                /*
                WHERE ASI_CRM_SG_Group_Outlet_Name__c  =: this.prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__r.ASI_CRM_SG_Group_Outlet_Name__c
                */
                WHERE id =: this.prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c
                AND ASI_CRM_SG_Image_Criteria_Set__r.Region__c =: this.prosSegmentation.Region__c
                LIMIT 1];
         
        if (tempGroupOutlet.size()>0){
                groupOutletInfo = tempGroupOutlet[0];
        }
        system.debug('groupOutletInfo :::' + groupOutletInfo);                                        
        return groupOutletInfo;
    }
    
    private void determimeProsAdmin(){
        isProsAdmin = false;
        List<PermissionSetAssignment> permSets = [SELECT PermissionSet.Id,PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE Assignee.Username =:UserInfo.getUserName()];
        if(permSets != null && permSets.size() >0 ){
            for(PermissionSetAssignment permSet: permSets){
                if((permSet.PermissionSet.Name).contains('ASI_CRM_MY')){
                    isProsAdmin = true;
                }
            }
        }
    }
    
    
}