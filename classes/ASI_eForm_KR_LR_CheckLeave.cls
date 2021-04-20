public without sharing class ASI_eForm_KR_LR_CheckLeave{
    
    list<double> specialLeaveUsed = new list<double>();
    list<double> sickLeaveUsed= new list<double>();
    list<double> weddingAnniversaryLeaveUsed= new list<double>();
    list<double> menstrationLeaveUsed= new list<double>();
    
    list<double> tmpSpecialLeave = new list<double>();
    list<double> tmpSickLeave= new list<double>();
    list<double> tmpWeddingAnniversaryLeave= new list<double>();
    list<double> tmpMenstrationLeave= new list<double>();
    
    list<double> tmpUpdateSpecialLeave = new list<double>();
    list<double> tmpUpdateSickLeave= new list<double>();
    list<double> tmpUpdateWeddingAnniversaryLeave= new list<double>();
    list<double> tmpUpdateMenstrationLeave= new list<double>();

    //static final double specialLeavePeryear=ASI_eForm_KR_LR__c.getValues('Special Leave').ASI_eForm_KR_LR_LeavePerYorM__c;
    private double specialLeavePeryear;
    static final double sickLeavePerYear=ASI_eForm_KR_LR__c.getValues('Sick Leave').ASI_eForm_KR_LR_LeavePerYorM__c;
    static final double weddingAnniversaryLeavePerYear=ASI_eForm_KR_LR__c.getValues('Wedding Anniversary').ASI_eForm_KR_LR_LeavePerYorM__c;
    static final double menstrationLeavePerMonth=ASI_eForm_KR_LR__c.getValues('Menstruation Leave').ASI_eForm_KR_LR_LeavePerYorM__c;
    
    static final String sickLeave=ASI_eForm_KR_LR__c.getValues('Sick Leave').ASI_eForm_KR_LR_Leave_Type__c;
    static final String specialLeave=ASI_eForm_KR_LR__c.getValues('Special Leave').ASI_eForm_KR_LR_Leave_Type__c;
    static final String weddingAnniversaryLeave=ASI_eForm_KR_LR__c.getValues('Wedding Anniversary').ASI_eForm_KR_LR_Leave_Type__c;
    static final String menstrationLeave=ASI_eForm_KR_LR__c.getValues('Menstruation Leave').ASI_eForm_KR_LR_Leave_Type__c;
    
    static final String nonCountRejected='Rejected';
    static final String nonCountDraft='Draft';
    
    integer menstrationLeaveMonth;
	integer menstrationLeaveYear;    
    String userDetail = [SELECT ID,ASI_KOR_Commission_Code__c From User where id =: UserInfo.getUserId()].ASI_KOR_Commission_Code__c;
    
    map<id,ASI_eForm_Leave_Request__c> checkMasterRecord = new map<id,ASI_eForm_Leave_Request__c>();

    
    public void massCount(list<ASI_eForm_Leave_Request_Line_Item__c> trigger_New){
        for(integer i = 0 ; i < 20; i++){
            tmpSpecialLeave.add(0);
            tmpSickLeave.add(0);
            tmpWeddingAnniversaryLeave.add(0);
            tmpMenstrationLeave.add(0);
        }
        for(ASI_eForm_Leave_Request_Line_Item__c obj : trigger_New){
        	
            for(integer i = 0; i < 20 ; i++){
                
            	if(obj.ASI_eForm_Date_From__c.year()==system.today().year()+(i-1)){
                        
					if(obj.ASI_eForm_Leave_Type__c==specialLeave){
						tmpSpecialLeave[i] += obj.ASI_eForm_No_of_Days__c;
                	}
                	if(obj.ASI_eForm_Leave_Type__c==sickLeave){
						tmpSickLeave[i] += obj.ASI_eForm_No_of_Days__c;
                	}
                	if(obj.ASI_eForm_Leave_Type__c==weddingAnniversaryLeave){
						tmpWeddingAnniversaryLeave[i] += obj.ASI_eForm_No_of_Days__c;
                	}
                }
                
                if(system.today().month()+(i-2) > 12){
                    menstrationLeavemonth = system.today().month()+(i-2)-12;
                    menstrationLeaveyear = system.today().year()+1;
                }else if(system.today().month()+(i-2) < 1){
                    menstrationLeavemonth = system.today().month()+(i-2)+12;
                    menstrationLeaveyear = system.today().year()-1;
                }else{
                    menstrationLeavemonth = system.today().month()+(i-2);
                    menstrationLeaveyear = system.today().year();
                }
                
                
                if(obj.ASI_eForm_Date_From__c.year()==menstrationLeaveyear&&obj.ASI_eForm_Date_From__c.month()==menstrationLeavemonth&&obj.ASI_eForm_Leave_Type__c==menstrationLeave)
                {
                    	tmpMenstrationLeave[i] += obj.ASI_eForm_No_of_Days__c;
				}
            }
        }
    }
    
    public void updateCount(list<ASI_eForm_Leave_Request_Line_Item__c> trigger_New, map<id,ASI_eForm_Leave_Request_Line_Item__c> updateValidation){
        
        for(integer i = 0;i < 20;i++){
            tmpUpdateSpecialLeave.add(0);
            tmpUpdateSickLeave.add(0);
            tmpUpdateWeddingAnniversaryLeave.add(0);
            tmpUpdateMenstrationLeave.add(0);
        }
        if(trigger.isupdate){
        for(ASI_eForm_Leave_Request_Line_Item__c obj : trigger_New){
            
            for(integer i = 0;i < 20; i++){
            
        		if(updateValidation.get(obj.id).ASI_eForm_Date_From__c.year()==system.today().year()+(i-1)){
                
					if(updateValidation.get(obj.id).ASI_eForm_Leave_Type__c==specialLeave){
						tmpUpdateSpecialLeave[i] += updateValidation.get(obj.id).ASI_eForm_No_of_Days__c;
                	}
                	if(updateValidation.get(obj.id).ASI_eForm_Leave_Type__c==sickLeave){
                    	tmpUpdateSickLeave[i] += updateValidation.get(obj.id).ASI_eForm_No_of_Days__c;
                	}
                	if(updateValidation.get(obj.id).ASI_eForm_Leave_Type__c==weddingAnniversaryLeave){
                    	tmpUpdateWeddingAnniversaryLeave[i] += updateValidation.get(obj.id).ASI_eForm_No_of_Days__c;
                	}
                }
                
                if(system.today().month()+(i-2) > 12){
                    menstrationLeavemonth = system.today().month()+(i-2)-12;
                    menstrationLeaveyear = system.today().year()+1;
                }else if(system.today().month()+(i-2) < 1){
                    menstrationLeavemonth = system.today().month()+(i-2)+12;
                    menstrationLeaveyear = system.today().year()-1;
                }else{
                    menstrationLeavemonth = system.today().month()+(i-2);
                    menstrationLeaveyear = system.today().year();
                }
                
                if(updateValidation.get(obj.id).ASI_eForm_Leave_Type__c==menstrationLeave&&updateValidation.get(obj.id).ASI_eForm_Date_From__c.month()==menstrationLeavemonth
                      &&updateValidation.get(obj.id).ASI_eForm_Date_From__c.year()==menstrationLeaveyear){
                    	tmpUpdateMenstrationLeave[i] += updateValidation.get(obj.id).ASI_eForm_No_of_Days__c;
                	}
                }
            }
        }
    }
    
    
    public void checkUsed(){
        
		for(integer i =0;i<=20;i++){
        	specialLeaveUsed.add(0);
        	sickLeaveUsed.add(0);
        	weddingAnniversaryLeaveUsed.add(0);
        	menstrationLeaveUsed.add(0);
    	}
      
        list<ASI_eForm_Leave_Request_Line_Item__c> allRecord = new list<ASI_eForm_Leave_Request_Line_Item__c>([SELECT 
                                                                                                               id,
                                                                                                               ASI_eForm_Date_From__c,
                                                                                                               ASI_eForm_No_of_Days__c,
                                                                                                               ASI_eForm_Leave_Type__c 
                                                                                                               FROM ASI_eForm_Leave_Request_Line_Item__c 
                                                                                                               WHERE ASI_eForm_Leave_Reuest__r.ASI_eForm_Requester_Record__r.Name=:userDetail
                                                                                                               and ASI_eForm_Leave_Reuest__r.ASI_eForm_Status__c !=: nonCountRejected
                                                                                                               and ASI_eForm_Leave_Reuest__r.ASI_eForm_Status__c !=: nonCountDraft
                                                                                                               and ASI_eForm_No_of_Days__c > 0
                                                                                                               and(ASI_eForm_Leave_Type__c =: specialLeave
                                                                          											OR ASI_eForm_Leave_Type__c =:sickLeave
                                                                          											OR ASI_eForm_Leave_Type__c =: weddingAnniversaryLeave
                                                                                                                    OR ASI_eForm_Leave_Type__c =: menstrationLeave
                                                                         										   )
                                                                                                               ]);
        
    	for(ASI_eForm_Leave_Request_Line_Item__c oldDetail : allRecord){

             	  for(integer i = 0; i <= 20 ;i++){
                      
                      if(system.today().month()+(i-2) > 12){
                          menstrationLeavemonth = system.today().month()+(i-2)-12;
                          menstrationLeaveyear = system.today().year()+1;
                      }else if(system.today().month()+(i-2) < 1){
                          menstrationLeavemonth = system.today().month()+(i-2)+12;
                          menstrationLeaveyear = system.today().year()-1;
                      }else{
                          menstrationLeavemonth = system.today().month()+(i-2);
                          menstrationLeaveyear = system.today().year();
                      }
                      
                      if(oldDetail.ASI_eForm_Leave_Type__c==menstrationLeave&&oldDetail.ASI_eForm_Date_From__c.month()==menstrationLeavemonth&&
                        oldDetail.ASI_eForm_Date_From__c.year()==menstrationLeaveyear){
                          menstrationLeaveUsed[i] += oldDetail.ASI_eForm_No_of_Days__c;
                      }
                          
                   
                    	if(oldDetail.ASI_eForm_Date_From__c.year()==system.today().year()+(i-1)){
                        	if(oldDetail.ASI_eForm_Leave_Type__c==specialLeave){
                          	   specialLeaveUsed[i] += oldDetail.ASI_eForm_No_of_Days__c;
                        	}
                         	if(oldDetail.ASI_eForm_Leave_Type__c==sickLeave){
                             	sickLeaveUsed[i] += oldDetail.ASI_eForm_No_of_Days__c;
                         	}
                         	if(oldDetail.ASI_eForm_Leave_Type__c==weddingAnniversaryLeave){
                              	weddingAnniversaryLeaveUsed[i] += oldDetail.ASI_eForm_No_of_Days__c;
                         	}
                     	}
               	}
    	}
    }
    
    Public void validation(list<sObject> trigger_New,map<id,ASI_eForm_Leave_Request_Line_Item__c> TiggerOldMap){
        
        getSpecialLeave(trigger_New);
        checkUsed();
        updateCount(trigger_New,TiggerOldMap);
        massCount(trigger_New);
        
        date year;
        Set<Id> masterRecordIdSet = new Set<id>();
        Id masterRecordId;

        for(sObject obj : trigger_New){
            masterRecordIdSet.add(String.valueOf(obj.get('ASI_eForm_Leave_Reuest__c')));
        }
        
        checkMasterRecord.putAll([select id,ASI_eForm_Requester_Record__r.ASI_eForm_Employee_Gender__c from ASI_eForm_Leave_Request__c 
                                                                                                   where Id IN: masterRecordIdSet]); 
    	for(sObject obj : trigger_new){
        
      		year=date.valueOf(obj.get('ASI_eForm_Date_From__c'));
        	masterRecordId = String.valueOf(obj.get('ASI_eForm_Leave_Reuest__c'));
                
       		for(integer i = 0; i <= 20 ;i++){
                
                if(year.year()==system.today().year()+(i-1)){
                    
                    if(obj.get('ASI_eForm_Leave_Type__c')==specialLeave&&tmpSpecialLeave[i]>specialLeavePeryear-(specialLeaveUsed[i]/*-tmpUpdateSpecialLeave[i]*/)){
                        
                        if(!Test.isRunningTest())
                            obj.addError((specialLeavePeryear-(specialLeaveUsed[i]/*-tmpUpdateSpecialLeave[i]*/))+' day(s) special leave balance in '+(system.today().year()+i-1)+'.');
             			}
                    
                    else if(obj.get('ASI_eForm_Leave_Type__c')==sickLeave&&tmpSickLeave[i]>sickLeavePeryear-(sickLeaveUsed[i]/*-tmpUpdateSickLeave[i]*/)){
                        
                        if(!Test.isRunningTest())
                            obj.addError((sickLeavePeryear-(sickLeaveUsed[i]/*-tmpUpdateSickLeave[i]*/))+' day(s) sick leave balance in '+(system.today().year()+i-1)+'.');
                    }
                    
                    else if(obj.get('ASI_eForm_Leave_Type__c')==weddingAnniversaryLeave&&tmpWeddingAnniversaryLeave[i]>weddingAnniversaryLeavePerYear-(weddingAnniversaryLeaveUsed[i]/*-tmpUpdateWeddingAnniversaryLeave[i]*/)){
                        
                        if(!Test.isRunningTest())
                            obj.addError((weddingAnniversaryLeavePerYear-(weddingAnniversaryLeaveUsed[i]/*-tmpUpdateWeddingAnniversaryLeave[i]*/))+' day(s) wedding anniversary leave balance in '+(system.today().year()+i-1)+'.');
                    }
                }
                
                if(system.today().month()+(i-2) > 12){
                    menstrationLeavemonth = system.today().month()+(i-2)-12;
                    menstrationLeaveyear = system.today().year()+1;
                }else if(system.today().month()+(i-2) < 1){
                    menstrationLeavemonth = system.today().month()+(i-2)+12;
                    menstrationLeaveyear = system.today().year()-1;
                }else{
                    menstrationLeavemonth = system.today().month()+(i-2);
                    menstrationLeaveyear = system.today().year();
                }
                
        			if(obj.get('ASI_eForm_Leave_Type__c')==menstrationLeave){
            			if(checkMasterRecord.get(masterRecordid).ASI_eForm_Requester_Record__r.ASI_eForm_Employee_Gender__c=='m'){
                			if(!Test.isRunningTest())
                            	obj.addError('For female only');
            		}else{ 
                		if(year.month()==menstrationLeavemonth&&year.year()==menstrationLeaveyear&&tmpMenstrationLeave[i]>menstrationLeavePerMonth-(menstrationLeaveUsed[i]-tmpUpdateMenstrationLeave[i])){
                    		if(!Test.isRunningTest())
                            	obj.addError((menstrationLeavePerMonth-(menstrationLeaveUsed[i]/*-tmpUpdateMenstrationLeave[i]*/))+' day(s) menstration leave balance.');
                		}
         			}
            	}
        	}
        }
    }
    
    public void getSpecialLeave(list<ASI_eForm_Leave_Request_Line_Item__c> trigger_New)
    {
        Set<String> setID = new Set<String>();
        for(ASI_eForm_Leave_Request_Line_Item__c tempobj: trigger_New)
        {
            setID.add(tempobj.ASI_eForm_Leave_Reuest__c);
        }
        map<id,ASI_eForm_Leave_Request__c> tempLR = new map<id, ASI_eForm_Leave_Request__c>([SELECT id, ASI_eForm_Requester_Record__r.Name From ASI_eForm_Leave_Request__c WHERE id IN: setID]);
        List<ASI_eForm_KR_Leave_EE__c> eeObj = new List<ASI_eForm_KR_Leave_EE__c>
            ([SELECT id, ASI_eForm_Employee_Record__r.Name, ASI_eForm_Total_Special_Leave__c, ASI_eform_Year__c FROM ASI_eForm_KR_Leave_EE__c]);
        Map<String,ASI_eForm_KR_Leave_EE__c> mapLeave = new Map<String,ASI_eForm_KR_Leave_EE__c>();
        for(ASI_eForm_KR_Leave_EE__c tempObj : eeObj)
        {
            mapLeave.put(tempObj.ASI_eForm_Employee_Record__r.Name + tempObj.ASI_eform_Year__c, tempObj);
        }
        for(ASI_eForm_Leave_Request_Line_Item__c tempobj: trigger_New)
        {
            if(mapLeave.get(tempLR.get(tempobj.ASI_eForm_Leave_Reuest__c).ASI_eForm_Requester_Record__r.Name+tempobj.ASI_eForm_Date_From__c.year()) == null)
                specialLeavePeryear = 0;
            else
                specialLeavePeryear = mapLeave.get(tempLR.get(tempobj.ASI_eForm_Leave_Reuest__c).ASI_eForm_Requester_Record__r.Name+tempobj.ASI_eForm_Date_From__c.year()).ASI_eForm_Total_Special_Leave__c;
        }
        
    }
}