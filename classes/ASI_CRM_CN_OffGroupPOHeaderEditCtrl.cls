/***************************************************************************************************************************
 * Name:        ASI_CRM_CN_OffGroupPOHeaderEditCtrl
 * Description: Apex class for ASI_CRM_CN_OffGroupPOHeaderEditCtrl
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-10-18       Jeffrey Cheung          Created
 * 2018-03-06       Keith Yip               Handle Promotion Group PO
 ****************************************************************************************************************************/

public class ASI_CRM_CN_OffGroupPOHeaderEditCtrl {
    public ASI_TH_CRM_Contract__c contract {set;get;}
    public String pageId {set;get;}
    public String contractId {set;get;}
    public String customerId {set;get;}
    public Boolean isEditable {set;get;}
    public String pageMessage {set;get;}

    public ASI_CRM_CN_OffGroupPOHeaderEditCtrl(ApexPages.StandardController controller) {
        Map<String, String> params = ApexPages.currentPage().getParameters();
        contractId = params.get('id');
        customerId = params.get('ASI_CRM_CN_Outlet_WS__c');
        isEditable = params.get('isEditable') == '1';

        // Group PO Edit page
        if (contractId != null) {
            pageId = contractId;
            contract = [
                SELECT
                    ASI_CRM_Active_Dummy_PO__c,
                    ASI_CRM_CN_PO_End_Date__c,
                    ASI_CRM_CN_PO_No__c,
                    ASI_CRM_CN_PO_Start_Date__c,
                    ASI_CRM_CN_Region__c,
                    ASI_CRM_CN_Status__c,
                    ASI_TH_CRM_Promotion_Type__c,
                    ASI_CRM_CN_PO_Version__c,
                    CreatedById,
                    Id,
                    Name,
                    OwnerId
                FROM ASI_TH_CRM_Contract__c
                WHERE Id = :contractId
            ];
        }

        // customerId != null => Group PO Creation
        if (customerId != null) {
            pageId = customerId;

            contract = new ASI_TH_CRM_Contract__c(
                ASI_CRM_CN_Outlet_WS__c = customerId,
                ASI_CRM_CN_PO_Version__c = '0.0',
                ASI_CRM_CN_Status__c = 'Draft',
                ASI_CRM_New_FY_PO__c = true,
                ASI_TH_CRM_Promotion_Type__c = 'TOT/MOT Group PO',
                Name = 'Automated, Do Not change',
                ASI_CRM_CN_PO_No__c = '',
                ASI_CRM_CN_Is_Group_Contract__c = true,
                RecordTypeId = Global_RecordTypeCache.getRtId('ASI_TH_CRM_Contract__cASI_CRM_CN_Contract')
            );
        }


    }

    public PageReference SaveItems() {
        PageReference pageRef = null;
        Boolean isNewContract = contract.Id == null;

        if (validationChecking()) {
            System.Savepoint pSavepoint = Database.setSavepoint();
            try {

                upsert contract;
                //if (isNewContract) {
                if (isNewContract && contract.ASI_TH_CRM_Promotion_Type__c !='Outlet Promotion' && contract.ASI_TH_CRM_Promotion_Type__c !='Consumer Promotion' && contract.ASI_TH_CRM_Promotion_Type__c !='Wholesaler Promotion') {    
                    insert ASI_CRM_CN_ContractOffUtilClass.GeneratingVolumeValueTargetLine(contract);
                }


                pageRef = new PageReference('/' + contract.Id);
                pageRef.setRedirect(true);

            } catch (Exception e) {
                pageMessage += ASI_CRM_CN_HeavyContracFunctionClass.ErrorMsgTransform(e.getMessage()) + '</br>';
                Database.rollback(pSavepoint);
            }

        }

        return pageRef;
    }

    public Boolean validationChecking(){
        Boolean isValid = true;
        pageMessage = '';

        if(contract.ASI_CRM_CN_PO_Start_Date__c == null){
            pageMessage += ' Please input Start Date.请输入开始日期' + '</br>';
            isValid =false;
        }

        if(contract.ASI_CRM_CN_PO_End_Date__c == null){
            pageMessage += ' Please input End Date.请输入结束日期' + '</br>';
            isValid =false;
        }


        if(!ASI_CRM_DateUtilClass.isStartOfMonth(contract.ASI_CRM_CN_PO_Start_Date__c)){
            pageMessage += Label.ASI_CRM_CN_PO_Start_Date_Validation+'<br/>';
            isValid =false;
        }

        //checking end day
        if(!ASI_CRM_DateUtilClass.isEndOfMonth(contract.ASI_CRM_CN_PO_End_Date__c)){
            pageMessage +=Label.ASI_CRM_CN_PO_End_Date_Validation+'<br/>';// End Date should be the last day of the month .
            isValid =false;
        }


        return isValid;
    }

    public PageReference cancel(){
        PageReference pageRef = new PageReference('/'+pageId);
        pageRef.setRedirect(true);
        return pageRef;
    }

}