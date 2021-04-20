public with sharing class ASI_CRM_JP_PrintPaymentController{
    private ASI_CRM_Call_Plan__c plan;
    public List<detailWrapper> displayList;
    private List<ASI_CRM_Call_Detail__c> detailList;
    public String paymentOpt{get;set;}
    public Boolean isSelectAll{get;set;}
    private Set<String> optList;
    public ASI_CRM_JP_PrintPaymentController(ApexPages.StandardController controller) {
        plan = (ASI_CRM_Call_Plan__c)controller.getRecord();
    }
    public List<detailWrapper> getDisplayList(){
        if(detailList == null){
            optList = new Set<String>();
            displayList = new List<detailWrapper>();
            detailList = [Select Id,
                                 ASI_CRM_Payment_Option__c, 
                                 ASI_CRM_TnE_Detail_No__c,
                                 ASI_CRM_Customer__c, 
                                 ASI_CRM_Call_Plan__c,
                                 ASI_CRM_Visit_Date_From__c,
                                 ASI_CRM_Visit_Date_To__c, 
                                 ASI_CRM_Activity_Result__c,
                                 ASI_CRM_Actual_Amount__c,
                                 ASI_CRM_Planned_Amount__c,
                                 ASI_CRM_Activity_Purpose__c,
                                 ASI_CRM_Activity_Sub_brand_1__c 
                                 From ASI_CRM_Call_Detail__c 
                                 Where ASI_CRM_Call_Plan__c =:plan.Id
                                 And (RecordType.DeveloperName = 'ASI_CRM_JP_Call_Result_Detail_Locked' OR RecordType.DeveloperName = 'ASI_CRM_JP_Call_Result_Detail_Invoice')];
            for(ASI_CRM_Call_Detail__c d:detailList){
                 if(!optList.contains(d.ASI_CRM_Payment_Option__c)){
                     optList.add(d.ASI_CRM_Payment_Option__c);
                 }
                 if(paymentOpt == null){
                     paymentOpt = d.ASI_CRM_Payment_Option__c;
                 }
            }
        }
        displayList = new List<detailWrapper>();
        for(ASI_CRM_Call_Detail__c d:detailList){
            if(d.ASI_CRM_Payment_Option__c == paymentOpt){
                if(isSelectAll == true){
                    detailWrapper wrapper = new detailWrapper(d);
                    wrapper.selected = true;
                    displayList.add(wrapper);
                }else{
                    displayList.add(new detailWrapper(d));
                }
            }
        }        
        return displayList;
    }
    public void changePaymentOpt(){
        getDisplayList();
    }
    public pageReference print(){
        List<Id> idList = new List<Id>();
        for(detailWrapper d:displayList){
            if(d.selected == true){
                idList.add(d.detail.Id);
            }
        }
        if(idList.size() > 0){
            return new pageReference('/apex/ASI_CRM_JP_CallDetailPrintPage?recs=' + String.join(idList, ','));
        }else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,System.Label.ASI_CRM_JP_PrintPaymentWarn));
            return null;
        }
    }
    public List<SelectOption> getOptions(){
        if(displayList == null){
            getDisplayList();
        }
        List<SelectOption> options = new List<SelectOption>();
        for(String str:optList){
            options.add(new SelectOption(str,str));
        }
        return options;
    }
    
    public void selectAll(){
        for(detailWrapper wrapper:displayList){
            wrapper.selected = true;
        }
    }
    
    public class detailWrapper{
        public Boolean selected{get;set;}
        public ASI_CRM_Call_Detail__c detail{get;set;}
        public detailWrapper(ASI_CRM_Call_Detail__c d){
            detail = d;
            selected = false;
        }
    } 
}