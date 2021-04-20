/*
    - This Controller controls the Page Traffic of the Contract Standard View Action.
*/
/***************************************************************************************************************************
 * Name:        ASI_CRM_RedirectContractView_Ctr
 * Description: Redirect to ASI_CRM_CN_PromotionContractPage if the promotion type is Outlet Promotion / Wholesaler Promotion
                / Consumer Promotion
 *
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2018-11-08       Keith Yip               Redirect to ASI_CRM_CN_PromotionContractPage if the promotion type is Outlet Promotion / 
                                            Wholesaler Promotion / Consumer Promotion
 ****************************************************************************************************************************/

public class ASI_CRM_RedirectContractView_Ctr {
    private ASI_TH_CRM_Contract__c contract{get;set;}
    private String recordTypeId{get;set;}
    private String recordId{get;set;}
    private String recordTypeName{get;set;}
    public PageReference redirectPage {get;set;}
    private String paramList {get;set;}
    
    public ASI_CRM_RedirectContractView_Ctr (ApexPages.StandardController controller) {
        
        Map<String, String> pageParam = ApexPages.currentPage().getParameters(); 
        paramList='';
        if(pageParam!=null){
            for(String param : pageParam.keySet()){
                if(pageParam.get(param)==null){
                    paramList +='&'+param+'=null';
                }else{
                    if(!param.contains('save_new')&&!param.contains('sfdc.override'))
                    paramList +='&'+param+'='+pageParam.get(param);
                }
            }
        }
        
        contract = (ASI_TH_CRM_Contract__c)controller.getRecord();
        recordTypeId = ((ASI_TH_CRM_Contract__c)controller.getRecord()).RecordTypeId;
        recordId = ((ASI_TH_CRM_Contract__c)controller.getRecord()).Id;
        recordTypeName = 'null';
        for(RecordType rt:[select id,DeveloperName from RecordType where id = :recordTypeId limit 1])
             recordTypeName = rt.DeveloperName;
    }
    public PageReference redirect(){
        //if RecordTypeName = 'ASI_TH_CRM_Contract', redirect to its default view page. if 'ASI_CRM_CN_Contract', redirect to page 'ASI_CRM_CN_MainContractPage'

        if(recordTypeName == 'ASI_TH_CRM_Contract')
        {
            Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
            redirectPage =  new PageReference('/'+ this.contract.id + '?nooverride=1'+ paramList);
            redirectPage.setRedirect(true);
        }
        else if(recordTypeName == 'ASI_CRM_CN_Contract') 
        {
            if(recordId!=null){ //Added by Laputa 20170525 for CRM 4.2 
                ASI_TH_CRM_Contract__c ContractSelected =[select Id,ASI_TH_CRM_Promotion_Type__c,ASI_CRM_CN_TP_Is_Trade_Plan_CN__c,ASI_CRM_CN_Is_2nd_KPI_PO__c from ASI_TH_CRM_Contract__c where id=:recordId];
                if(ContractSelected.ASI_TH_CRM_Promotion_Type__c!=null &&  ContractSelected.ASI_TH_CRM_Promotion_Type__c=='Heavy Contract On'){
                    if (ContractSelected.ASI_CRM_CN_Is_2nd_KPI_PO__c) {
                        redirectPage =  new PageReference('/apex/ASI_CRM_CN_ViewHeavyContractPage2nd?id='+ recordId); // ASI_CRM_CN_MainHeavyContractPage  ASI_CRM_CN_ViewHeavyContractPage
                    }
                    else {
                        redirectPage =  new PageReference('/apex/ASI_CRM_CN_ViewHeavyContractPage?id='+ recordId); // ASI_CRM_CN_MainHeavyContractPage  ASI_CRM_CN_ViewHeavyContractPage
                    }
                    
                }else if(ContractSelected.ASI_TH_CRM_Promotion_Type__c != null &&
                   ( ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Contract' || ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Group PO')) {
                    redirectPage =  new PageReference('/apex/ASI_CRM_CN_ViewContractOffPage?id='+ recordId);
                //<<Modified by Keith 2018-11-08
                }else if(ContractSelected.ASI_TH_CRM_Promotion_Type__c != null &&
                   ( ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Outlet Promotion' || ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Wholesaler Promotion' || ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'Consumer Promotion')) {
                    redirectPage =  new PageReference('/apex/ASI_CRM_CN_PromotionContractPage?id='+ recordId);
                //>>Modified by Keith 2018-11-08    
                }else if(ContractSelected.ASI_CRM_CN_TP_Is_Trade_Plan_CN__c){
                    //modified by alex 2020-03-12 for cn trade plan project
                    redirectPage =  new PageReference('/apex/ASI_CRM_CN_TP_PODetail?id='+ recordId);
                }else{
                    redirectPage =  new PageReference('/apex/ASI_CRM_CN_MainContractPage?id='+ recordId);
                }
            }
        }
        else if(recordTypeName == 'ASI_SG_CRM_Contract') 
        {
            Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
            redirectPage =  new PageReference('/'+ this.contract.id + '?nooverride=1'+ paramList);
            redirectPage.setRedirect(true);
        }//Added by Laputa
        else if(recordTypeName.startsWith('ASI_CRM_MY_Contract')) 
        {
            Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
            redirectPage =  new PageReference('/apex/ASI_CRM_Contract_Standard?id='+ this.contract.id + paramList);
            redirectPage.setRedirect(true);
        }
        else if(recordTypeName.startsWith('ASI_CRM_MO_Contract')) 
        {
            Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
            redirectPage =  new PageReference('/apex/ASI_CRM_Contract_Standard?id='+ this.contract.id + paramList);
            redirectPage.setRedirect(true);
        }
        else
        {
            Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
            redirectPage =  new PageReference('/'+ this.contract.id + '?nooverride=1'+ paramList);
            redirectPage.setRedirect(true);
        }
        
        return redirectPage;
    }

}