/*
    - This Controller controls the Page Traffic of the TW MFM Plan PDF generation.
*/

public class ASI_MFM_RedirectPlanPDF_Ctr {
    private ASI_MFM_Plan__c plan = new ASI_MFM_Plan__c();
    private String recordTypeId{get;set;}
    private String recordId{get;set;}
    public PageReference redirectPage {get;set;}
    
    public ASI_MFM_RedirectPlanPDF_Ctr (ApexPages.StandardController controller) {
        
        recordTypeId = ((ASI_MFM_Plan__c)controller.getRecord()).RecordTypeId;
        recordId = ((ASI_MFM_Plan__c)controller.getRecord()).Id;
        plan = [select id, ASI_MFM_Sys_Plan_Type__c from ASI_MFM_Plan__c where id = :recordId];
    }
    public PageReference redirect(){
        

        if(plan.ASI_MFM_Sys_Plan_Type__c == 'Trade A&P and A&D Plan'  ){//redirectPage = new PageReference('/apex/ASI_MFM_TW_Plan2In1Pdf_Page?id='+recordId);
            redirectPage = new PageReference('/apex/ASI_MFM_TW_Plan2In1PDF_Page_ver2?id='+recordId);
        }else if(plan.ASI_MFM_Sys_Plan_Type__c == 'Mixed Plan'){//redirectPage = new PageReference('/apex/ASI_MFM_TW_Plan2In1Pdf_Page?id='+recordId);
            redirectPage = new PageReference('/apex/ASI_MFM_TW_Plan2In1PDF_Page_ver3?id='+recordId);
        }else {//redirectPage = new pageReference('/apex/ASI_MFM_plan_pdf_page?id='+recordId);
            redirectPage = new pageReference('/apex/ASI_MFM_TW_Plan_PDF_Page?id='+recordId);
        }
        redirectPage.setRedirect(true);
        return redirectPage;
    }
}