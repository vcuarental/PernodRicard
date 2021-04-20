public class ASI_MFM_CN_ImportationDocRedirect_Ctrl {

    private ASI_MFM_Importation_Document__c reocrd{get;set;}
    private String recordTypeId{get;set;}
    private String recordId{get;set;}
    private String recordTypeName{get;set;}
    public PageReference redirectPage {get;set;}
    public String retURL{get;set;}
    private String paramList {get;set;}
    
    public ASI_MFM_CN_ImportationDocRedirect_Ctrl (ApexPages.StandardController controller) {
        
        recordTypeId = ((ASI_MFM_Importation_Document__c )controller.getRecord()).RecordTypeId;
        recordId = ((ASI_MFM_Importation_Document__c)controller.getRecord()).Id;
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
            Schema.DescribeSObjectResult describeOpp = Schema.SObjectType.ASI_MFM_Importation_Document__c;    
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
    }
    
    public PageReference redirect(){
        //if RecordTypeName = 'ASI_TH_CRM_Contract', redirect to its default create page. if 'ASI_CRM_CN_Contract', redirect to page 'ASI_CRM_CN_EditContractPage'
        
        System.debug(recordtypeName);
        if(recordTypeName == 'ASI_MFM_CN_Importation_Document'){
            redirectPage =  new PageReference('/apex/ASI_MFM_CN_ImportationDocNoticPage?RecordType='+recordTypeId + '&retURL='+retURL);
            
        }else{
            
            Schema.DescribeSObjectResult obj = ASI_MFM_Importation_Document__c.sObjectType.getDescribe();
            if(recordTypeId != null)
                redirectPage = new PageReference('/'+ obj.getKeyPrefix() +'/e?RecordType='+recordtypeid+'&nooverride=1'+ paramList);
        }
        
        return redirectPage;
    }
}