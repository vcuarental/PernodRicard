global class EXT_USR_RQT_AddUserGroupWS {   
	
    /*############################################################################
    #   A.T.T.R.I.B.U.T.E.S
    ##############################################################################*/
    /**
     * CodeReturn : Object return by the webservice
     */ 
    global class CodeReturn {
        webservice String error;
        webservice String code;
    }  
    
    /**
     * EXT_USR_RQT_Wrapper : Object in parameters to the webservice.
     */ 
    global class EXT_USR_RQT_Wrapper {
    	webservice String Company;
    	webservice String FirstName;
    	webservice String LastName;
    	webservice Datetime ExpiryDate;
    	webservice String Alias;
    	webservice String Email;
    	webservice String Username;
    	webservice String Nickname;
    	webservice String ExtUserID;
    	webservice String requestID;
    	webservice String groupID;
    } 
    
    /*############################################################################
    #   C.O.N.S.T.R.U.C.T.O.R
    ##############################################################################*/
    /*
     * Main method. calls others method in order.
     ***/
    webservice static CodeReturn[] addUserToGroup(EXT_USR_RQT_Wrapper myRqt) {  
        List<CodeReturn> listeCodeReturn = new List<CodeReturn>();
        Boolean err = false;
        String userID;
        CodeReturn crU;
        if(myRqt.ExtUserID != null && myRqt.ExtUserID != ''){
			/* Update the User */
			crU = updateExtUser(myRqt);
			
			//check result
			if(crU.code == 'OK'){
				userID = crU.error;
			}else{
				err = true;
				listeCodeReturn.add(crU);
        		return listeCodeReturn;
			}
		}else{
			/* Create a new User */
			crU = createNewExtUser(myRqt);
			
			//check result
			if(crU.code == 'OK'){
				myRqt.ExtUserID = crU.error;
				System.resetPassword(myRqt.ExtUserID, true);
			}else{
				err = true;
				listeCodeReturn.add(crU);
       			return listeCodeReturn;
			}
		}   			
		
		/* Update the request */
		
		if(crU.code == 'OK'){
			CodeReturn crR = updateRequest(myRqt);
			//check result
			if(crR.code == 'KO'){
				err = true;
				listeCodeReturn.add(crR);
	    		return listeCodeReturn;
			}
		}
    	
    	/* Add the user to the group */	
        //Check if user not already in this group.
        Integer nbSearch = [SELECT count() FROM CollaborationGroupMember where MemberId =: myRqt.groupID AND CollaborationGroupId =: myRqt.ExtUserID];    
        
        // If not already added, added the user to the group.
        if(nbSearch == 0){
    		CollaborationGroupMember entMember = new CollaborationGroupMember (CollaborationGroupId = myRqt.groupID, MemberId = myRqt.ExtUserID);
	    	try{
	    		insert entMember;
	        }catch(Exception e){ 
	    		if(!e.getMessage().contains('DUPLICATE_VALUE')){
		            err = true;
		            listeCodeReturn.add(addCodeReturn('KO','Exception during insert the member ['+myRqt.ExtUserID+'] in the group ['+myRqt.groupID+'] : '+ e.getMessage()+ ', Error Type :=' + e.getTypeName()));  
	    			return listeCodeReturn;
	    		}
	        }
        }
	    
	    /* Check errors. if no error, return OK */
        if(err==false){
            listeCodeReturn.add(addCodeReturn('OK','Everything is OK.'));   
        }
        
        /* RETOUR */        
        return listeCodeReturn;
    }
       
    /*
     * Update the request with info stored in the wrapper object 
     ***/ 
    public static CodeReturn updateRequest(EXT_USR_RQT_Wrapper myRqt){ 
    	External_User_Request__c rqt = new External_User_Request__c(Id=myRqt.requestID);
    	rqt.EXT_USE_RQT_Expiry_Date__c = myRqt.ExpiryDate;
		rqt.EXT_USR_RQT_External_User__c = myRqt.ExtUserID;
		rqt.EXT_USR_RQT_Acceptance_Date__c = Datetime.now();
		try{
			update rqt;
		}catch(Exception e){
            return addCodeReturn('KO','Exception during update the request ['+myRqt.requestID+']: '+ e.getMessage()+ ', Error :=' + e.getTypeName()); 
		} 
		return addCodeReturn('OK','');
    }
       
    /*
     * Update the External User with info stored in the wrapper object 
     ***/
    public static CodeReturn updateExtUser(EXT_USR_RQT_Wrapper myRqt){
    	User usr = new User(Id = myRqt.ExtUserID);
    	usr.IsActive = true;
		usr.ESNPolicyAcceptanceDate__c = Datetime.now();
		usr.EXT_USR_RQT_Expiration_Status__c = 'Active';
		usr.BypassTriggers__c = 'Autofollow_User_InsertUpdate,AutoJoin_User_InsertUpdate';
		
		usr.FirstName = myRqt.FirstName;
		usr.LastName = myRqt.LastName;
		usr.CompanyName = myRqt.Company;
		usr.EXT_USR_RQT_Expiration_Date__c = myRqt.ExpiryDate;
		
		try{
			update usr;
		}catch(Exception e){
            return addCodeReturn('KO','Exception during update the user [Name:'+usr.Name+'/Id:'+myRqt.ExtUserID+'/RQT:'+myRqt.requestID+']: '+ e.getMessage()+ ', Error :=' + e.getTypeName()); 
		}
		return addCodeReturn('OK',''+usr.Id);
    }
       
    /*
     * Create a new External User with info stored in the wrapper object 
     ***/
    public static CodeReturn createNewExtUser(EXT_USR_RQT_Wrapper myRqt){
    	User usr = new User();
    	usr.IsActive = true;
		usr.Alias = myRqt.Alias;
		usr.Email = myRqt.Email;
		usr.Username = myRqt.Username;
		usr.CommunityNickname = myRqt.Nickname;
		usr.FirstName = myRqt.FirstName;
		usr.CompanyName = myRqt.Company;
		usr.LastName = myRqt.LastName;
		usr.ProfileId = EXT_USR_Config__c.getOrgDefaults().EXT_USR_RQT_External_Profile_Id__c;
		
		usr.EXT_USR_RQT_Expiration_Date__c = myRqt.ExpiryDate;		
		usr.ESNPolicyAcceptanceDate__c = Datetime.now();
		usr.EXT_USR_RQT_Expiration_Status__c = 'Active';
		
		usr.BypassTriggers__c = 'Autofollow_User_InsertUpdate,AutoJoin_User_InsertUpdate';
		
		// standard required fields 
		usr.TimeZoneSidKey = 'Europe/London';
		usr.LocaleSidKey = 'en_US'; 
		usr.EmailEncodingKey = 'UTF-8'; 
		usr.LanguageLocaleKey ='en_US';
		
		try{
			insert usr;
		}catch(Exception e){
            return addCodeReturn('KO','Exception during insert the user [Name:'+usr.FirstName+' '+usr.LastName+'/Username:'+usr.Username+'/RQT:'+myRqt.requestID+']: '+ e.getMessage()+ ', Error :=' + e.getTypeName()); 
		}
		return addCodeReturn('OK',''+usr.Id);
    }

    /*
     * Constructor for the CodeReturn object
     ***/
    public static CodeReturn addCodeReturn(String code, String msg){
        CodeReturn codeReturn = new CodeReturn();
        CodeReturn.error = msg;
        CodeReturn.code = code;
        return codeReturn;
    }
}