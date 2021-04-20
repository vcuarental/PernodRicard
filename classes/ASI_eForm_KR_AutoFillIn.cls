public without sharing class ASI_eForm_KR_AutoFillIn {
        
    public static void fillInMethod(list<sObject> TRIGGER_NEW,String field){
        

        
	    String UserDetail =[SELECT ID,ASI_KOR_Commission_Code__c From User where id =: UserInfo.getUserId()].ASI_KOR_Commission_Code__c;
        if(UserDetail==null)
            UserDetail='norecord';
        list<ASI_eForm_HR_MDM__c> obj = new list<ASI_eForm_HR_MDM__c>([SELECT ID,Name From ASI_eForm_HR_MDM__c WHERE Name =: UserDetail]);
        
        
        for(sObject newRequest : TRIGGER_NEW){
            
            if(obj.isEmpty())
            {
            	newRequest.addError('MDM record does not exist for the requester.');
            }
            
        	else if(newRequest.get(field)==null){
                
        		for(ASI_eForm_HR_MDM__c loopMDMDetail : obj){
           	 		if(String.valueOf(loopMDMDetail.Name)==UserDetail){
              	  		newRequest.put(field,loopMDMDetail.id);
                    }//end if
                }//end for
            }//end if
            
        }//endfor
        
    }//end fillInMethod
}//end ASI_eForm_KR_AutoFillIn