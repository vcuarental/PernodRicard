public with sharing class ASI_MFM_SubmitPlanController {
    ASI_MFM_Plan__c p = new ASI_MFM_Plan__c();
    private String recordId{get;set;}
    
    public ASI_MFM_SubmitPlanController(apexpages.standardController sc) {
        recordId = ((ASI_MFM_Plan__c)sc.getRecord()).Id;
    }
    
    public pageReference genPDF() {
        pageReference pdf;
        
        //Modified by William Yang 2014-06-19
        p = [select id, ASI_MFM_Sys_Plan_Type__c from ASI_MFM_Plan__c where id = :recordId];
        if(p.ASI_MFM_Sys_Plan_Type__c == 'Trade A&P and A&D Plan')
            //pdf = new pageReference('/apex/ASI_MFM_TW_Plan2In1Pdf_Page'); //20160516, Leo@Elufa
            pdf = new pageReference('/apex/ASI_MFM_TW_Plan2In1PDF_Page_ver2');
        //20170411, Elufa
        else if(p.ASI_MFM_Sys_Plan_Type__c == 'Mixed Plan')
            pdf = new pageReference('/apex/ASI_MFM_TW_Plan2In1PDF_Page_ver3');
        //20170411, Elufa
        else
            //pdf = new pageReference('/apex/ASI_MFM_plan_pdf_page'); //20160516, Leo@Elufa
            pdf = new pageReference('/apex/ASI_MFM_TW_Plan_PDF_Page');
        pdf.getParameters().put('id', p.id);
        attachment ach = new attachment(
            parentId = p.id,                         
            name = 'Plan PDF Form',
            contentType = 'application/pdf',
            body = test.isRunningTest() ? blob.valueOf('Test') : pdf.getContent());
        insert ach;
        
       // return new pageReference('/p/process/Submit?retURL=%2F' + p.id + '&id=' + p.id);  
        
         return new pageReference('/apex/ASI_SubmitApprovalPage?id=' + p.id);   
    }
}