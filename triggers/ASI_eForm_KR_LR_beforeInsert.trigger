trigger ASI_eForm_KR_LR_beforeInsert on ASI_eForm_Leave_Request__c (before insert){ 

    //if(Global_RecordTypeCache.getRt(trigger.new[0].recordTypeId).developerName.contains('ASI_eForm_KR'))
    //{
    	ASI_eForm_KR_AutoFillIn.fillInMethod(trigger.new,'ASI_eForm_Requester_Record__c');
    //}

    /*integer lofCount=0;
    integer slCount=0;
    integer mlCount=0;
    double alCount=0;
    
    static final String sickLeave=ASI_eForm_KR_LR__c.getValues('Sick Leave').ASI_eForm_KR_LR_Leave_Type__c;
    //static final String leaveOfAbsence=ASI_eForm_KR_LR__c.getValues('Leave of Absence').ASI_eForm_KR_LR_Leave_Type__c;
    static final String maternityLeave=ASI_eForm_KR_LR__c.getValues('Maternity Leave').ASI_eForm_KR_LR_Leave_Type__c;
    
    //list<ASI_eForm_KR_Leave_EE__c> EE= new list<ASI_eForm_KR_Leave_EE__c>([SELECT id,ASI_eForm_Local_Employee_ID__c,ASI_eform_Year__c from ASI_eForm_KR_Leave_EE__c]);
    list<ASI_eForm_Leave_Request_Line_Item__c> existingLRD = new list<ASI_eForm_Leave_Request_Line_Item__c>([SELECT id,ASI_eForm_Leave_Type__c,ASI_eForm_No_of_Days__c,ASI_eForm_Leave_Reuest__c from ASI_eForm_Leave_Request_Line_Item__c where ASI_eForm_Leave_Reuest__c IN: trigger.new]);
    
    for(ASI_eForm_Leave_Request__c LR : trigger.new){

        //for(ASI_eForm_KR_Leave_EE__c obj : EE){
        //    if(LR.ASI_eForm_Requester_ID__c==obj.ASI_eForm_Local_Employee_ID__c&&LR.CreatedDate.year()==obj.ASI_eform_Year__c){
        //        LR.ASI_eForm_Leave_Employee_Entitlement__c=obj.id;
        //    }
        //}

        
        for(ASI_eForm_Leave_Request_Line_Item__c obj : existingLRD){
            
            if(obj.ASI_eForm_Leave_Type__c.containsignorecase('Leave of Absence')){
                lofCount++;}
            if(obj.ASI_eForm_Leave_Type__c==sickLeave){
                slCount++;}
            if(obj.ASI_eForm_Leave_Type__c==maternityLeave){
                mlCount++;}
            if(obj.ASI_eForm_Leave_Type__c.containsignorecase('Annual Leave')){
                alCount+=obj.ASI_eForm_No_of_Days__c;
            }
        }
            if(lofCount==0){
                LR.ASI_eForm_Leave_of_Absence__c=false;
            }else{LR.ASI_eForm_Leave_of_Absence__c=true;}
            
            if(mlCount==0){
                LR.ASI_eForm_LR_Maternity_Leave__c=false;
            }else{LR.ASI_eForm_LR_Maternity_Leave__c=true;}

            if(slCount==0){
                LR.ASI_eForm_LR_Sick_Leave__c=false;
            }else{LR.ASI_eForm_LR_Sick_Leave__c=true;}
            LR.Sum_of_Annual_Leave__c=alCount;
        
    }*/
}