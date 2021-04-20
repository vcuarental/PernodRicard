/*
    - This Controller controls the Page Traffic of the Contract Standard Edit Action.
*/

public class ASI_CRM_RedirectContractEdit_Ctr {
    private ASI_TH_CRM_Contract__c contract{get;set;}
    private String recordTypeId{get;set;}
    private String recordId{get;set;}
    private String recordTypeName{get;set;}
    public PageReference redirectPage {get;set;}
        
    public ASI_CRM_RedirectContractEdit_Ctr (ApexPages.StandardController controller) {
        
        recordTypeId = ((ASI_TH_CRM_Contract__c)controller.getRecord()).RecordTypeId;
        recordId = ((ASI_TH_CRM_Contract__c)controller.getRecord()).Id;
        recordTypeName = 'null';
        for(RecordType rt:[select id,DeveloperName from RecordType where id = :recordTypeId limit 1])
             recordTypeName = rt.DeveloperName;
    }
    public PageReference redirect(){
        //if RecordTypeName = 'ASI_TH_CRM_Contract', redirect to its default edit page. if 'ASI_CRM_CN_Contract', redirect to page 'ASI_CRM_CN_EditContractPage'

        if(recordTypeName == 'ASI_TH_CRM_Contract')
        {
            Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
            redirectPage =  new PageReference('/'+recordId+'/e?retURL=%2F'+ recordId +'&nooverride=1');
        }
        else if(recordTypeName == 'ASI_CRM_CN_Contract') 
        {
            
            if(recordId!=null){ //Added by Laputa 20170525 for CRM 4.2 batch2
                ASI_TH_CRM_Contract__c ContractSelected =[select Id,ASI_TH_CRM_Promotion_Type__c,ASI_CRM_CN_Status__c from ASI_TH_CRM_Contract__c where id=:recordId];
                if(ContractSelected.ASI_CRM_CN_Status__c!='Draft'){
                     redirectPage =  new PageReference('/apex/ASI_CRM_CN_HeavyErrorPage');
                    
                }else if(ContractSelected.ASI_TH_CRM_Promotion_Type__c!=null &&  ContractSelected.ASI_TH_CRM_Promotion_Type__c=='Heavy Contract On'){
                    redirectPage =  new PageReference('/apex/ASI_CRM_CN_HeavyContractHeaderEditPage?id='+ recordId);
                } else if (ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Contract' || ContractSelected.ASI_TH_CRM_Promotion_Type__c == 'TOT/MOT Group PO') {
                    redirectPage = new PageReference('/apex/ASI_CRM_CN_OffContractHeaderEditPage?id=' + recordId);
                } else {
                    redirectPage =  new PageReference('/apex/ASI_CRM_CN_EditContractPage?RecordType='+recordTypeId + '&id=' + recordId);
                }
            }
            
        }
    else if(recordTypeName == 'ASI_CRM_PH_Contract' || recordTypeName == 'ASI_CRM_PH_Contract_Read_Only')
        {
             Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
             redirectPage =  new PageReference('/'+recordId+'/e?retURL=%2F'+ recordId +'&nooverride=1');
        }
    else if(recordTypeName == 'ASI_CRM_CN_Group_Contract') {
            Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
            redirectPage =  new PageReference('/'+recordId+'/e?retURL=%2F'+ recordId +'&nooverride=1');
        }else if(recordTypeName == 'ASI_CRM_CN_Local_Group_Contract' || recordTypeName=='ASI_CRM_CN_Local_Group_Contract_Final') {
            Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
            redirectPage =  new PageReference('/'+recordId+'/e?retURL=%2F'+ recordId +'&nooverride=1');
        }
        //Added by Laputa
        else if(recordTypeName == 'ASI_CRM_SG_Contract') 
        {
             Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
             redirectPage =  new PageReference('/'+recordId+'/e?retURL=%2F'+ recordId +'&nooverride=1');
        }
        //Added by Laputa
        else if(recordTypeName == 'ASI_CRM_SG_Contract_Read_Only') 
        {
             Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
             redirectPage =  new PageReference('/'+recordId+'/e?retURL=%2F'+ recordId +'&nooverride=1');
        }
        //Added by Laputa 2016-04-11
        else if(recordTypeName == 'ASI_CRM_SG_Proposal') 
        {
            // DC - 04/13/2016 - Added logic for SG Proposal page redirection [START]
            /*
            Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
            redirectPage =  new PageReference('/'+recordId+'/e?retURL=%2F'+ recordId +'&nooverride=1');
            */
            //redirectPage = Page.ASI_CRM_SG_EditContractPage;
            //redirectPage.getParameters().put('id', recordId);
            redirectPage =  new PageReference('/apex/ASI_CRM_SG_EditContractPage?id=' + recordId);
            // DC - 04/13/2016 - [END]
        }
        //Added by Laputa 2016-04-11
        else if(recordTypeName == 'ASI_CRM_SG_Proposal_Read_Only') 
        {
            // DC - 04/13/2016 - Added logic for SG Proposal page redirection [START]
            /*
            Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
            redirectPage =  new PageReference('/'+recordId+'/e?retURL=%2F'+ recordId +'&nooverride=1');
            */
            redirectPage = Page.ASI_CRM_SG_EditContractPage;
            redirectPage.getParameters().put('id', recordId);
            // DC - 04/13/2016 - [END]
        }
        // 2014-12-29   For Malaysia Contract Edit Page
        else if(recordTypeName.startsWith('ASI_CRM_MY_Contract'))
        {
             Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
             redirectPage =  new PageReference('/'+recordId+'/e?retURL=%2F'+ recordId +'&nooverride=1');
        }
        else if(recordTypeName.startsWith('ASI_CRM_MO_Contract'))
        {
             Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
             redirectPage =  new PageReference('/'+recordId+'/e?retURL=%2F'+ recordId +'&nooverride=1');
        }
        return redirectPage;
    }

}