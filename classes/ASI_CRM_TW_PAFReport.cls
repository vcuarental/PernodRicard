public with sharing class ASI_CRM_TW_PAFReport {
    public ASI_HK_CRM_Pre_Approval_Form__c dummyPAF {get;set;}
    public List<SelectOption> statusOptionList {get;set;}
    public List<String> selectedStatus {get;set;}
    public List<ASI_HK_CRM_Pre_Approval_Form__c>  pafList {get;set;}
    public Boolean renderResult {get;set;}

    public ASI_CRM_TW_PAFReport() {
        selectedStatus = new List<String>();
        dummyPAF = new ASI_HK_CRM_Pre_Approval_Form__c();
        dummyPAF.ASI_HK_CRM_PAF_Start_Date__c = null;
        dummyPAF.ASI_HK_CRM_PAF_End_Date__c = null;
        renderResult = false;
        statusOptionList = new List<SelectOption>();
        statusOptionList.add(new SelectOption('None', 'None'));
        statusOptionList.add(new SelectOption('Draft', 'Draft'));
        statusOptionList.add(new SelectOption('Final', 'Final'));
        statusOptionList.add(new SelectOption('Complete', 'Complete'));
    }

    public PageReference DownloadExcel()
    {
        Boolean runDownload = true;
        ApexPages.getMessages().clear();
        if(selectedStatus.size() == 0){
            runDownload = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Specify At Least One Status'));
        }
        if(dummyPAF.ASI_HK_CRM_PAF_Start_Date__c == null){
            runDownload = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Select Start Date'));
        }
        if(dummyPAF.ASI_HK_CRM_PAF_End_Date__c == null) {
            runDownload = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Select End Date'));
        }
        if(dummyPAF.ASI_HK_CRM_PAF_End_Date__c < dummyPAF.ASI_HK_CRM_PAF_Start_Date__c){
            runDownload = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Start Date Should Be Earlier than End Date'));
        }
        if(runDownload) {
            ApexPages.getMessages().clear();
            pageReference pg = new pageReference('/apex/ASI_CRM_TW_PAFReport_ExportCSV');
            pg.getParameters().put('selectedStatus',string.join(selectedStatus, ','));
            pg.getParameters().put('startDate',String.valueof(dummyPAF.ASI_HK_CRM_PAF_Start_Date__c));
            pg.getParameters().put('endDate',String.valueof(dummyPAF.ASI_HK_CRM_PAF_End_Date__c));
            pg.setRedirect(true);
            return pg;
        }
        return null;
    }
}