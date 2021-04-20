public with sharing class LAT_BR_VFP_31_NovoCadastroOverride {
   
    private String RecordTypeId{get;set;}
    private String RecordTypeName{get;set;}
    private final string userID;
    private String paramList {get;set;} // store parameters from previos page and pass it to the next

    public LAT_BR_VFP_31_NovoCadastroOverride(){
        userID = Userinfo.getUserID();
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
    }

	public pageReference authorized (){
        if(Utils.isPartOfMobileCRM(userID)){
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, label.LAT_BR_VFP31_CadastroCliente);
            ApexPages.addMessage(myMsg);
            return null;   
            
        }
        Schema.DescribeSObjectResult accObj = Account.sObjectType.getDescribe();
        PageReference retPage = new PageReference('/'+ accObj.getKeyPrefix() +'/e?RecordType='+recordtypeid+'&nooverride=1'+ paramList);
        if (recordtypeid == null)
            retPage = new PageReference('/'+ accObj.getKeyPrefix() +'/e?nooverride=1'+ paramList);
        retPage.setRedirect(true);
        return retPage;
    }
}