/******************************************************************
*Name:ASI_CRM_JP_ContractRedirectController
*Description: Controller for ASI_CRM_JP_ContractRedirectPage
*Change History:
*Date           Developer      Details
*April 8,2016   Hank           Created 
*
******************************************************************/
public without sharing class ASI_CRM_JP_ContractRedirectController{
    public ASI_CRM_Purchase_Contract__c contract;
    private String paramList {get;set;} 
    private String RecordTypeId{get;set;}
    private String RecordTypeName{get;set;}
    public ASI_CRM_JP_ContractRedirectController(ApexPages.StandardController controller) {
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
        system.debug('----- paramList : ' + paramList);
        contract = (ASI_CRM_Purchase_Contract__c)controller.getRecord();
        RecordTypeId = ((ASI_CRM_Purchase_Contract__c)controller.getRecord()).RecordTypeId;
        RecordTypeName = '';
        if(RecordTypeId != null){
            RecordType rt = [select id,DeveloperName from recordtype where id = :RecordTypeId];
            RecordTypeName = rt.DeveloperName;
        }
    }
    public pageReference redirect(){
        Map<String, ASI_CRM_Redirect_Tbl__c> tblMap = ASI_CRM_Redirect_Tbl__c.getAll();
        Schema.DescribeSObjectResult planObj = ASI_CRM_Purchase_Contract__c.sObjectType.getDescribe();
        PageReference retPage;
        if(tblMap.get(RecordTypeName) != null){
            retPage = new PageReference('/'+ planObj.getKeyPrefix() +'/e?RecordType='+recordtypeid+'&'+tblMap.get(RecordTypeName).ASI_CRM_Element_Id__c+'='+tblMap.get(RecordTypeName).ASI_CRM_Element_Value__c+'&nooverride=1'+ paramList);
        }else{
            retPage = new PageReference('/'+ planObj.getKeyPrefix() +'/e?RecordType='+recordtypeid+'&nooverride=1'+ paramList);
        }
        return retPage;
    }
}