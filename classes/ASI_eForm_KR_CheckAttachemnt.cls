public without sharing class ASI_eForm_KR_CheckAttachemnt {
    
    public static void checkAttachment(List<sObject> triggerNew,String field){

    	String status = 'Submitted';
        Set<String> objID = new Set<String>();
        for(sObject obj : triggerNew){
            objID.add(obj.id);
        }
        list<Attachment> a =new list<Attachment>([Select name,parentID,Id from Attachment where parentid IN: objID]); 
        map<id,Attachment> mapAttachment = new Map<id,Attachment>();
        for(Attachment obj : a){
            mapAttachment.put(obj.parentID,obj);
        }
        
        //String queryStr = 'SELECT ID,(SELECT ID from Attachments) from ' + objName + ' Where ID = \'' + triggerNew[0].id + '\'';
        
        
		//Map<id,sObject> mapAttachment = new Map<id,sObject>(database.query(queryStr));
        
        system.debug('check111 ' + mapAttachment);
    	
        for(sobject Parent : triggerNew){
            if((mapAttachment.get(Parent.id))==null&&Parent.get(field)==status){
                	if(!Test.isRunningTest())
            			Parent.addError('Attachment required for approval.');
            }
        }
    }
    
    public static void checkLeaveType(List<ASI_eForm_Leave_Request__c> triggerNew,String field)
    {
        list<ASI_eForm_Leave_Request_Line_Item__c> leaveFormDetail = new list<ASI_eForm_Leave_Request_Line_Item__c>
            ([Select id,ASI_eForm_Leave_Type__c,ASI_eForm_No_of_Days__c,ASI_eForm_Leave_Reuest__c From ASI_eForm_Leave_Request_Line_Item__c Where ASI_eForm_Leave_Reuest__c In: triggerNew]);
    	Map<id,ASI_eForm_Leave_Request_Line_Item__c> leaveDetailInfo = new Map<id,ASI_eForm_Leave_Request_Line_Item__c>();
    	//put the data into map object
    	for(ASI_eForm_Leave_Request_Line_Item__c childInfo : leaveFormDetail)
    	{
        	leaveDetailInfo.put(childInfo.ASI_eForm_Leave_Reuest__c, childInfo);
    	}//end for
    	for(ASI_eForm_Leave_Request__c Parent : triggerNew)
    	{	
        	if(leaveDetailInfo.get(Parent.id)!=null)
        	{
            	if(leaveDetailInfo.get(Parent.id).ASI_eForm_Leave_Type__c=='병가휴직 Sick Leave of Absence'
                   || leaveDetailInfo.get(Parent.id).ASI_eForm_Leave_Type__c=='예비군 훈련 Reserve forces training'
                   || (leaveDetailInfo.get(Parent.id).ASI_eForm_Leave_Type__c=='병가 휴가 Sick Leave' && leaveDetailInfo.get(Parent.id).ASI_eForm_No_of_Days__c >=2))
        		{
            		checkAttachment(triggerNew,field);
        		}
    		}
    	}
    }
}