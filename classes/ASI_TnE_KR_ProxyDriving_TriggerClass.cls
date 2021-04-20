public without sharing class ASI_TnE_KR_ProxyDriving_TriggerClass {

    static list<ASI_eForm_HR_MDM__c> MDM = new list<ASI_eForm_HR_MDM__c>([SELECT id,Name,ASI_eForm_Employee_Eligible_PD__c From ASI_eForm_HR_MDM__c]);
    private static String statusApproved = 'Approved';
    private static String statusCompleted = 'Completed';
    private static String statusFinal = 'Final';
    //custom setting
    private static final String companyCode222=ASI_TnE_KR_proxyBrand__c.getValues('222-PRK').ASI_TnE_KR_CompanyCode__c;
    private static final String companyCode286=ASI_TnE_KR_proxyBrand__c.getValues('286-PRKI').ASI_TnE_KR_CompanyCode__c;
    private static final String brandCode222=ASI_TnE_KR_proxyBrand__c.getValues('222-PRK').ASI_TnE_KR_proxyBrandCode__c;
    private static final String brandCode286=ASI_TnE_KR_proxyBrand__c.getValues('286-PRKI').ASI_TnE_KR_proxyBrandCode__c;
    
    public static void beforeUpdateMethod(List<ASI_TnE_Proxy_Driving_Request__c> triggerNew){
        
        map<id,ASI_eForm_HR_MDM__c> mapMDM2 = new map<id,ASI_eForm_HR_MDM__c>(MDM);
    
        for(ASI_TnE_Proxy_Driving_Request__c obj : triggerNew){
            if(mapMDM2.get(obj.ASI_TnE_Requestor_Record__c)!=null){
            	if(mapMDM2.get(obj.ASI_TnE_Requestor_Record__c).ASI_eForm_Employee_Eligible_PD__c==false){
                	obj.addError('You are not eligible for Proxy Driving');
                }
            }
        }
    }
    
    public static void beforeInsertMethod(List<ASI_TnE_Proxy_Driving_Request__c> triggerNew){
        
        //added by Leo, 2015-11-04
        List<ASI_TnE_KR_ProxyDrivingTransaction__c> listPDT
            = new List<ASI_TnE_KR_ProxyDrivingTransaction__c>([SELECT Id, ASI_TnE_KR_MDM_Employee_No__r.Name 
                                                               FROM ASI_TnE_KR_ProxyDrivingTransaction__c 
                                                               WHERE RecordType.DeveloperName = 'ASI_TnE_KR_PD_Transaction']);
        Map<String,ASI_TnE_KR_ProxyDrivingTransaction__c> mapPDT = new Map<String,ASI_TnE_KR_ProxyDrivingTransaction__c>();
        
        for(ASI_TnE_KR_ProxyDrivingTransaction__c obj : listPDT){
            mapPDT.put(obj.ASI_TnE_KR_MDM_Employee_No__r.Name,obj);
        }
        //added by Leo, 2015-11-04
        
        map<String,ASI_eForm_HR_MDM__c> mapMDM = new map<String,ASI_eForm_HR_MDM__c>(MDM);

        for(ASI_eForm_HR_MDM__c obj : MDM){
            mapMDM.put(obj.Name,obj);
        }
        for(ASI_TnE_Proxy_Driving_Request__c claimHeader : triggerNew){
            if(mapMDM.get(claimHeader.ASI_TnE_Requester_ID__c)==null)
            {
                claimHeader.addError('Employee ID : ' +claimHeader.ASI_TnE_Requester_ID__c + ' not found in MDM.');
            }
            else if(mapPDT.get(claimHeader.ASI_TnE_Requester_ID__c)==null)//added by Leo, 2015-11-04
            {
                claimHeader.addError('Employee ID : ' +claimHeader.ASI_TnE_Requester_ID__c + ' not found in Proxy Driving Transaction.');
            }//added by Leo, 2015-11-04
            else
            {
                claimHeader.ASI_TnE_Requestor_Record__c=mapMDM.get(claimHeader.ASI_TnE_Requester_ID__c).id;
                claimHeader.ASI_TnE_KR_ProxyDrivingTransaction__c=mapPDT.get(claimHeader.ASI_TnE_Requester_ID__c).id;//added by Leo, 2015-11-04
            }
        }//end for
        
        //added by Leo,2015-06-03
        set<String> commissionCodeSet = new Set<String>();
        Map<id,User> mapUser = new Map<id,User>([SELECT id,Name,ASI_KOR_Commission_Code__c FROM User WHERE ASI_KOR_Commission_Code__c!=null]);
        for(ASI_TnE_Proxy_Driving_Request__c obj : triggerNew)
        {
            if(mapUser.get(obj.OwnerId).ASI_KOR_Commission_Code__c!=null&&mapUser.get(obj.OwnerId).ASI_KOR_Commission_Code__c.trim()!='')
            {
            	commissionCodeSet.add(mapUser.get(obj.OwnerId).ASI_KOR_Commission_Code__c);
            }//end if
            else
            {
                obj.addError('User : ' + mapUser.get(obj.OwnerId).Name + ' don\'t have a commission code please edit user profile.');
            }//end else
        }//end for
        List<ASI_eForm_HR_MDM__c> recordOfMDM = new List<ASI_eForm_HR_MDM__c>([SELECT ID,Name,ASI_eForm_Employee_Branch_Code__c, ASI_eForm_Employee_Company_Code__c,ASI_eForm_Employee_Company_Name_MDM__c FROM ASI_eForm_HR_MDM__c WHERE Name IN: commissionCodeSet]);
        Map<String,ASI_eForm_HR_MDM__c> mapMDMz = new Map<String,ASI_eForm_HR_MDM__c>();
        
        for(ASI_eForm_HR_MDM__c obj : recordOfMDM){
            mapMDMz.put(obj.Name,obj);
        }
        
        for(ASI_TnE_Proxy_Driving_Request__c obj : triggerNew){
            if(mapUser.get(obj.OwnerId).ASI_KOR_Commission_Code__c!=null)
            {
                if(mapMDMz.get(mapUser.get(obj.OwnerId).ASI_KOR_Commission_Code__c)!=null
                   &&mapMDMz.get(mapUser.get(obj.OwnerId).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Branch_Code__c!=null
                   &&mapMDMz.get(mapUser.get(obj.OwnerId).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Company_Code__c!=null)
                {
                	obj.ASI_TnE_Requester_Department__c = mapMDMz.get(mapUser.get(obj.OwnerId).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Branch_Code__c;
                	obj.ASI_TnE_Requester_Company__c = mapMDMz.get(mapUser.get(obj.OwnerId).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Company_Code__c +'-'+ mapMDMz.get(mapUser.get(obj.OwnerId).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Company_Name_MDM__c;
                    if(mapMDMz.get(mapUser.get(obj.OwnerId).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Company_Code__c == companyCode222)
                    {
                        obj.ASI_TnE_Brand__c = brandCode222;
                    }
                    else if(mapMDMz.get(mapUser.get(obj.OwnerId).ASI_KOR_Commission_Code__c).ASI_eForm_Employee_Company_Code__c == companyCode286)
                    {
                        obj.ASI_TnE_Brand__c = brandCode286;
                    }
            	}//end if
                else
                {
                	obj.addError('User : ' + mapUser.get(obj.OwnerId).Name + '(' + mapUser.get(obj.OwnerId).ASI_KOR_Commission_Code__c + ') don\'t have a MDM record or missing branch code/company code.');
            	}//end else
            }//end if
        }//end for
        //added by Leo,2015-06-03
    }//end method:beforeInsertMethod
}