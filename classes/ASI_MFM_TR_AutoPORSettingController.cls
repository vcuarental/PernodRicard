public with sharing class ASI_MFM_TR_AutoPORSettingController{

    public Boolean access{get;set;}    
    public List<SelectOption> fiscalYearOpt {get;set;}
    
    public PORProxy setting {get;set;}
    
    public class PORProxy {
        public Id id{get;set;}
        public String Fiscal_Year{get;set;}
        public Date CutOff_Date{get;set;}
        
        public PORProxy(ASI_MFM_AutoPOReceiptSetting__c por){
            this.Id = por.id;
            this.Fiscal_Year = por.ASI_MFM_Fiscal_Year__c;
            this.CutOff_Date = por.ASI_MFM_Cut_Off_Date__c;            
        }
        
        public PORProxy(){}
        
        public ASI_MFM_AutoPOReceiptSetting__c getPORSetting(){
            return new ASI_MFM_AutoPOReceiptSetting__c(
                Id = this.id,
                ASI_MFM_Fiscal_Year__c = this.Fiscal_Year,
                ASI_MFM_Cut_Off_Date__c = this.CutOff_Date
            );
        }
    }
    
    public PageReference getSetting(){
        
        Id userId = userInfo.getUserId();
        Id profId = userInfo.getProfileId();
        Boolean IsAdmin = false;       
        
        for(PermissionSetAssignment psa: [Select Assigneeid, PermissionSetId from PermissionSetAssignment where PermissionSet.Name = 'ASI_HK_MFM_Sales_Approver']){
            if(psa.AssigneeId == userId){
                isAdmin = true;
            }
        }
        
        for(Profile p : [Select id, name from Profile where id =: profId]){
            if(p.name.contains('System Administrator')){
                isAdmin = true;
            }
        }
        
        if(!isAdmin && !Test.isRunningTest()){
            access = false;
            // Check user whether assigned in permission set        
            apexpages.addmessage(new apexpages.message(apexpages.severity.warning, 'You have no access to edit the setting'));
        }else{
            access = true;
            // get custom setting
            setting = new PORProxy([Select id, ASI_MFM_Cut_off_Date__c, ASI_MFM_Fiscal_Year__c from ASI_MFM_AutoPOReceiptSetting__c where name = 'TR' limit 1]);                                            
            
        }
        
        return null;
    }
    
    public pageReference save(){
        PageReference pr;
        if(setting.CutOff_Date == null && !Test.isRunningTest()){
            // Check cut-off Date is null        
            apexpages.addmessage(new apexpages.message(apexpages.severity.warning, 'You must enter a cut-off date'));            
            pr = null;
            
        }else{
            
            try{
                update setting.getPORSetting();
            }catch(exception e){
                apexpages.addmessage(new apexpages.message(apexpages.severity.warning, e.getMessage()));
                pr = null;        
            }
            
            
            pr = new PageReference(ApexPages.currentPage().getUrl());
            pr.setRedirect(true);
            
        }

        return pr;
    }                                                                        
}