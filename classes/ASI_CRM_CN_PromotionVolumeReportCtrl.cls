/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_PromotionVolumeReportCtrl
 * Description: Apex class for ASI_CRM_CN_PromotionVolumeReportCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2019-03-18       Jeffrey Cheung          Created
 ****************************************************************************************************************************/

public class ASI_CRM_CN_PromotionVolumeReportCtrl {
    public ASI_TH_CRM_Contract__c contract { set; get; }


    public String msg { get; set; } {
        msg = '';
    }
    public Boolean ProcessPermission { get; set; }{
        ProcessPermission = true;
    }
    public Date startDate { set; get; }
    public Date endDate { set; get; }
    public Id contractId {get; set;}
    public String startDateStr {get; set;}
    public String endDateStr {get; set;}

    public ASI_CRM_CN_PromotionVolumeReportCtrl() {
        // DateStr exist after clicking proceed
        Map<String, String> params = ApexPages.currentPage().getParameters();
        System.debug(params.get('startDate'));
        System.debug(params.get('endDate'));
        contractId = params.get('id');
        startDateStr = params.get('startDate');
        endDateStr = params.get('endDate');
        contract = [SELECT Id,Name, ASI_CRM_CN_Outlet_WS__r.Name, ASI_CRM_CN_Outlet_WS__r.ASI_CRM_CN_Legal_Name__c,ASI_CRM_CN_PO_Start_Date__c, ASI_CRM_CN_PO_No__c, ASI_CRM_CN_PO_End_Date__c FROM ASI_TH_CRM_Contract__c WHERE Id = :contractId];
        startDate = contract.ASI_CRM_CN_PO_Start_Date__c;
        endDate = contract.ASI_CRM_CN_PO_End_Date__c;

    }

    public PageReference CTDProceed(){
        Date CutOffDay = ASI_CRM_CN_HeavyContractUtilitiesClass.GenerateCutOffDate();
        endDate = ASI_CRM_DateUtilClass.findMinMaxDate(contract.ASI_CRM_CN_PO_End_Date__c, CutOffDay, 'MIN');
        return proceed();
    }

    public PageReference proceed() {
        ValidationChecking();

        System.debug(ProcessPermission);

        if (ProcessPermission) {
            System.debug(startDate);
            System.debug(endDate);
            PageReference pageReference = new PageReference('/apex/ASI_CRM_CN_PromotionVolumeReportPDF');
            pageReference.getParameters().put('id', contract.Id);
            pageReference.getParameters().put('startDate', String.valueOf(startDate));
            pageReference.getParameters().put('endDate', String.valueOf(endDate));
            pageReference.setRedirect(true);

            return pageReference;
        } else {
            return null;
        }
    }


    public void ValidationChecking() {
        ProcessPermission = true;
        msg = '';

        //1) show warning if user not choosing the 1st date as start date and last date as end date.
        //2) Reminder user if the period they selection volume is not ready.


        //checking the start day
        if (!ASI_CRM_DateUtilClass.isStartOfMonth(startDate)) {
            msg += Label.ASI_CRM_CN_PO_Start_Date_Validation + '<br/>';
            ProcessPermission = false;
        }

        //checking end day
        if (!ASI_CRM_DateUtilClass.isEndOfMonth(endDate)) {
            msg += Label.ASI_CRM_CN_PO_End_Date_Validation + '<br/>';// End Date should be the last day of the month .
            ProcessPermission = false;
        }

        if (startDate > endDate) {
            msg += Label.ASI_CRM_CN_PO_start_date_after_PO_end_date + '<br/>';//You cannot select PO start date after PO end date
            ProcessPermission = false;
        }


        if (contract.ASI_CRM_CN_PO_Start_Date__c < startDate) {
            msg += Label.ASI_CRM_CN_Start_date_validation + '<br/>';//Start date cannot exceed PO start date
            ProcessPermission = false;
        }

        if (endDate > contract.ASI_CRM_CN_PO_End_Date__c) {
            msg += Label.ASI_CRM_CN_End_date_validation + '<br/>';//End date cannot exceed PO start date
            ProcessPermission = false;
        }


//        ASI_CRM_CN_HeavyContractUtilitiesClass.ReturnResult checkingResult = ASI_CRM_CN_HeavyContractUtilitiesClass.CheckingVolumeIsReady(contract.ASI_CRM_CN_PO_Start_Date__c, contract.ASI_CRM_CN_PO_End_Date__c);
//
//        if (ProcessPermission) {
//            ProcessPermission = checkingResult.Process;
//        }
//
//
//        msg += checkingResult.Msg;

    }

}