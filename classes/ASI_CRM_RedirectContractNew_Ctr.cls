/*
    - This Controller controls the Page Traffic of the Contract Standard New Action.
*/

public class ASI_CRM_RedirectContractNew_Ctr {
    private ASI_TH_CRM_Contract__c contract{get;set;}
    private String recordTypeId{get;set;}
    private String recordId{get;set;}
    private String recordTypeName{get;set;}
    public PageReference redirectPage {get;set;}
    public String retURL{get;set;}
    private String paramList {get;set;} // store parameters from previos page and pass it to the next
  
    
    public ASI_CRM_RedirectContractNew_Ctr (ApexPages.StandardController controller) {

        recordTypeId = ((ASI_TH_CRM_Contract__c)controller.getRecord()).RecordTypeId;
        recordId = ((ASI_TH_CRM_Contract__c)controller.getRecord()).Id;
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        
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
        
        // handle user with only one record type
        if(recordTypeId  == null){
            Schema.DescribeSObjectResult describeOpp = Schema.SObjectType.ASI_TH_CRM_Contract__c;    
            List<Schema.RecordTypeInfo> rtInfos = describeOpp.getRecordTypeInfos();
            system.debug(rtInfos);
            for(Schema.RecordTypeInfo rtInfo : rtInfos) {
                System.debug(rtInfo);
                System.debug(rtInfo.isDefaultRecordTypeMapping());
                // For only one record type available user
                if(rtInfo.isAvailable() && rtInfo.getName() != 'Master') {               
                    //ApexPages.currentPage().getParameters().put('RecordType', rtInfo.getRecordTypeId());
                    recordTypeId  = rtInfo.getRecordTypeId();
                    break;
                }
            }
            
        }
        
        recordTypeName = 'null';
        System.debug(recordTypeId);
        if(recordTypeId != '' && recordTypeId != null){
            Recordtype rt = Global_RecordTypeCache.getRt(recordTypeId);
            recordTypeName = rt.DeveloperName;
        }
        /*for(RecordType rt:[select id,DeveloperName from RecordType where id = :recordTypeId limit 1]){
            recordTypeName = rt.DeveloperName;
            system.debug(recordtypeName);     
        }*/
    }
    public PageReference redirect(){
        //if RecordTypeName = 'ASI_TH_CRM_Contract', redirect to its default create page. if 'ASI_CRM_CN_Contract', redirect to page 'ASI_CRM_CN_EditContractPage'
        
        System.debug(recordtypeName);
        if(recordTypeName == 'ASI_CRM_CN_Contract') 
        {
            redirectPage =  new PageReference('/apex/ASI_CRM_CN_EditContractPage?RecordType='+recordTypeId + '&retURL='+retURL);
        }
        else if(recordTypeName == 'ASI_CRM_PH_Contract'){
		 
             Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
									
             redirectPage = new PageReference('/'+ contractObj.getKeyPrefix() +'/e?nooverride=1&retURL='+retURL + '&Name=[Auto-generated]&RecordType='+ recordtypeid);
        }		
        else if(recordTypeName.contains('ASI_CRM_MY'))
        {
            Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
            if(recordTypeId != null)
                redirectPage = new PageReference('/'+ contractObj.getKeyPrefix() +'/e?RecordType='+recordtypeid+'&nooverride=1'+ paramList+'&Name=Auto-generated Number');
        }
        else if(recordTypeName.contains('ASI_CRM_MO'))
        {
            List<ASI_CRM_MO_Settings__c> lstMOSetting = [SELECT ASI_CRM_MO_Field_ID_Exchange_Rate__c FROM ASI_CRM_MO_Settings__c WHERE ASI_CRM_MO_Field_ID_Exchange_Rate__c != NULL LIMIT 1];
            string strFieldExchangeRate;
            
            if(lstMOSetting != NULL && lstMOSetting.size() > 0)
            	strFieldExchangeRate = lstMOSetting[0].ASI_CRM_MO_Field_ID_Exchange_Rate__c;
            
            Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
            if(recordTypeId != null)
                redirectPage = new PageReference('/'+ contractObj.getKeyPrefix() +'/e?RecordType='+recordtypeid+'&nooverride=1'+ paramList+'&Name=Auto-generated Number&' + strFieldExchangeRate + '=');
        }
        else if(recordTypeName.contains('ASI_CRM_SG') || recordTypeName.contains('ASI_SG_CRM'))
        {
            // DC - 04/12/2016 - Added logic for SG Proposal page redirection [START]
            if(recordTypeName.contains('ASI_CRM_SG_Proposal') || recordTypeName.contains('ASI_CRM_SG_Proposal_Read_Only')) {
                if(recordTypeId != null) {
                    redirectPage = Page.ASI_CRM_SG_EditContractPage;
                    redirectPage.getParameters().put('RecordType', recordTypeId);
                }
                redirectPage.getParameters().putAll(ApexPages.currentPage().getParameters());
            }
            // DC - 04/12/2016 - [END]
            else {
                Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
                if(recordTypeId != null)
                    redirectPage = new PageReference('/'+ contractObj.getKeyPrefix() +'/e?RecordType='+recordtypeid+'&nooverride=1'+ paramList+'&Name=[Auto-generated]');
                //else{
                //    redirectPage = new PageReference('/'+ contractObj.getKeyPrefix() +'/e?nooverride=1&retURL='+retURL);
                //}
                //redirectPage =  new PageReference('/'+ contractObj.getKeyPrefix() +'/e?RecordType='+recordTypeId+'&nooverride=1&retURL='+retURL+'&Name=Auto-generated Number');
            }

        }
        else {
            Schema.DescribeSObjectResult contractObj = ASI_TH_CRM_Contract__c.sObjectType.getDescribe();
            if(recordTypeId != null)
                //redirectPage =  new PageReference('/'+ contractObj.getKeyPrefix() +'/e?RecordType='+recordTypeId+'&nooverride=1&retURL='+retURL);
                redirectPage = new PageReference('/'+ contractObj.getKeyPrefix() +'/e?RecordType='+recordtypeid+'&nooverride=1'+ paramList);
            else{
                redirectPage =  new PageReference('/'+ contractObj.getKeyPrefix() +'/e?nooverride=1&retURL='+retURL);
            }
        }
		
        return redirectPage;
    }

}