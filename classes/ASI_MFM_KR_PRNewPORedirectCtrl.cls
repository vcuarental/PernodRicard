public class ASI_MFM_KR_PRNewPORedirectCtrl {
    private ASI_MFM_Purchase_Request__c pr;
    
    public ASI_MFM_KR_PRNewPORedirectCtrl(ApexPages.StandardController controller)
    {
        pr = (ASI_MFM_Purchase_Request__c)controller.getRecord();
        pr = [Select id,name,ASI_MFM_Plan__c,ASI_MFM_Exchange_Rate__c,ASI_MFM_Expiration_Date__c,ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c,ASI_MFM_Prefix__c,ASI_MFM_Prefix__r.name,ASI_MFM_Currency__c, ASI_MFM_Ship_To__c, ASI_MFM_Ship_To__r.name,ASI_MFM_KR_Ship_to_Address__c
             from ASI_MFM_Purchase_Request__c where Id=: pr.Id];
    }
    
  
    public PageReference redirect()
    {
        string FieldId_Plan = '';
        string FieldId_Prefix = '';
        string FieldId_PlanName = '';
        string FieldId_ShipToAddress = '';
        
        String url;
        
        
        ASI_MFM_Prefix__c px_id=[select id from ASI_MFM_Prefix__c where ASI_MFM_Inactive__c = false and ASI_MFM_country_name__c='KR' and ASI_MFM_Module__c='PO' and name=: pr.ASI_MFM_Prefix__r.name limit 1 ];

        
        List<ASI_MFM_Field_ID_Mappings__c> Settings = ASI_MFM_Field_ID_Mappings__c.getAll().values();
        for (ASI_MFM_Field_ID_Mappings__c Setting : Settings)
        {
            if(Setting.ASI_MFM_Object_Name__c == 'ASI_MFM_PO__c')
            {          
                if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_Company_Address__c' ) FieldId_ShipToAddress = Setting.ASI_MFM_Field_ID__c;  //Added by Kammy
                if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_Plan__c') FieldId_Plan = Setting.ASI_MFM_Field_ID__c;
                if(Setting.ASI_MFM_Field_Name__c == 'ASI_MFM_PO_Name__c' ) FieldId_PlanName = Setting.ASI_MFM_Field_ID__c;
                
                //
            }
        }
        url = '/' + ASI_MFM_PO__c.SObjectType.getDescribe().getKeyPrefix() +
            '/e?RecordType=' + string.valueOf(Global_RecordTypeCache.getRtId('ASI_MFM_PO__cASI_MFM_KR_PO')).subString(0,15) + 
            '&planname=' + EncodingUtil.urlEncode(pr.ASI_MFM_Plan__r.ASI_MFM_Plan_Name__c, 'UTF-8')+
            '&prid=' + pr.Id+
            '&prname=' + pr.name+
            '&ExRate='+String.valueOf(pr.ASI_MFM_Exchange_Rate__c)+
            '&currencyName=' + pr.ASI_MFM_Currency__c+
             //'&shiptoaddress=' + pr.ASI_MFM_KR_Ship_to_Address__c+
            '&retURL=%2F' + pr.ASI_MFM_Plan__c+'&pid=' + pr.ASI_MFM_Plan__c;
        
        
        if(pr.ASI_MFM_KR_Ship_to_Address__c != null) {
            url +='&shiptoaddress=' +EncodingUtil.urlEncode(pr.ASI_MFM_KR_Ship_to_Address__c, 'UTF-8');
        }//if(pr.ASI_MFM_KR_Ship_to_Address__c != null) {url +='&shiptoaddress=' + pr.ASI_MFM_KR_Ship_to_Address__c;}//system.assertEquals(pr.ASI_MFM_KR_Ship_to_Address__c,null);
        
        if(pr.ASI_MFM_Ship_To__c!=null) {
            url+='&shiptoid=' + pr.ASI_MFM_Ship_To__c+'&shiptoname=' + pr.ASI_MFM_Ship_To__r.name ;
        }  
        if(pr.ASI_MFM_Expiration_Date__c!=null){
            //ExpirationDate
            url+='&ExpirationDate='+pr.ASI_MFM_Expiration_Date__c.format(); 
        }
        
            
        if(px_id!=null){ url+='&prefixid='+px_id.id;}
        
        /*
        if(pr.ASI_MFM_KR_Ship_to_Address__c!=null){ 
            url+= '&shiptoaddress='  + pr.ASI_MFM_KR_Ship_to_Address__c;
        }  */
        
        //SYSTEM.assertEquals(url,NULL);  
       //url = 'https://pernod-ricard--asisb6conf.cs8.my.salesforce.com/a9A/e?00ND0000005pd2j=KRW&00ND0000005r8bV=0312%09Tony+Test&CF00ND0000005pd30=21025001&CF00ND0000005pd30_lkid=a9EL00000008cIyMAI&CF00ND0000005pd31=PRKI&CF00ND0000005pd31_lkid=a9FL00000009O5KMAU&CF00NL0000003kpps=16000011&CF00NL0000003kpps_lkid=aHJL00000008Oz6OAE&CF00NL0000003kxcw=Agency&CF00NL0000003kxcw_lkid=001L000000qC5SlIAK&Name=PRKI&nooverride=1&00NL0000003XGCQ=TEST&RecordType=012L0000000DKsT&retURL=%2Fa9A%2Fo';
        return new PageReference(url);
    }
    
    
}