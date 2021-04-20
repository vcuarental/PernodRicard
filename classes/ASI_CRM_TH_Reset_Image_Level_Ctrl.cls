/*********************************************************************************
 * Name: ASI_CRM_TH_Reset_Image_Level_Ctrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 04/03/2016       Introv: Twinkle LI      Cloned from ASI_CRM_TW_Reset_Image_Level_Ctrl
*********************************************************************************/

public with sharing class ASI_CRM_TH_Reset_Image_Level_Ctrl{
    
    private ApexPages.StandardController standardController;        
    public ASI_CRM_Pros_Segmentation__c prosSegmentation{get;set;}
    private Id groupOutId {get;set;}
    public String ImageId {get;set;}
    public String Comment {get;set;}
    public String currentImageId {get;set;}
    
    public ASI_CRM_TH_Reset_Image_Level_Ctrl(ApexPages.StandardController standardController)
    {
    
        this.standardController = standardController;
        if(this.standardController.getId() != null){  
            returnProsSegmentation();
            groupOutId = prosSegmentation.ASI_CRM_SG_Group_Outlet_Type__c;
            ImageId = prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__c;
            currentImageId = prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c;            
        }       
    }
    
    public void returnProsSegmentation(){
        prosSegmentation = ASI_CRM_TH_ProsSegmentationClass.returnProsSegmentationviaId(this.standardController.getId());
    }
    
    
    public List<SelectOption> getImageLevels(){
        
        List<SelectOption> imageOption = new List<SelectOption>();
        system.debug('**'+ImageId);
        for(ASI_CRM_Image_Level_Threshold__c ilt : [SELECT Id, ASI_CRM_SG_Image_Level_Name__c, ASI_CRM_SG_Image_Level__c FROM ASI_CRM_Image_Level_Threshold__c WHERE ASI_CRM_SG_Group_Outlet_Type__c =: groupOutId]){
            if(ilt != null && Imageid != null && Id.valueOf(ImageId.substringBeforeLast('&')) != ilt.Id){
                imageOption.add(new SelectOption(ilt.Id+'&'+ilt.ASI_CRM_SG_Image_Level_Name__c+'@'+prosSegmentation.ASI_CRM_SG_Image_Level_Threshold__r.ASI_CRM_SG_Image_Level_Name__c,ilt.ASI_CRM_SG_Image_Level_Name__c));
            }
        }        
        return imageOption;
    }
    
    public PageReference submitApproval(){
        
        try{
            ASI_CRM_AccountsAdditionalField__c cust = [SELECT Id, ASI_CRM_SG_SYS_New_Image_Level_Threshold__c FROM ASI_CRM_AccountsAdditionalField__c WHERE Id =: prosSegmentation.ASI_CRM_SG_Customer__c LIMIT 1];
            cust.ASI_CRM_SG_SYS_New_Image_Level_Threshold__c = ImageId;
            update cust;
            
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setObjectId(cust.Id);
            req1.setProcessDefinitionNameOrId('ASI_CRM_SG_Image_Level_Approval');
            req1.setComments(Comment);
            req1.setSkipEntryCriteria(true);
            
            Approval.ProcessResult result = Approval.process(req1);
            System.debug(result.isSuccess());
            
            if(result.isSuccess()){
                PageReference pageRef = new PageReference('/'+prosSegmentation.ASi_CRM_SG_Customer__c);
                return pageRef;
            }
            else{
                return null;
            }
        }        
        catch(Exception e){
            if(e.getMessage().contains('ALREADY_IN_PROCESS')){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Customer has pending approval process to change image level'));
            }
            else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));
            }
            return null;
        }        
    }
}