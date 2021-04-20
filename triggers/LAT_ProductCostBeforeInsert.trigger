/*
* LAT_ProductCostBeforeInsert
* Author: Martin Prado (martin@zimmic.com)
* Date: 11/16/2016
*/
trigger LAT_ProductCostBeforeInsert on LAT_ProductCost__c (before insert, before update) {

  List<Boolean> profileCanUdapte = canUpdate();
  if(Trigger.isUpdate) {
    for ( LAT_ProductCost__c pc : trigger.new ) {
      // User can't edit
      if(!profileCanUdapte.get(0)){
        pc.addError(System.Label.LAT_BR_PC_ErrorPermissionNotAllow);
      } else {
        // Trade Profile can only modify end date
        if(!profileCanUdapte.get(1)){
          //End Date must be in future
          if(pc.EndDate__c < datetime.now().addSeconds(-30)){
            pc.EndDate__c.addError(System.Label.LAT_BR_PC_ErrorPermissionClosed);
          }
          LAT_ProductCost__c oldPC = Trigger.oldMap.get(pc.Id);

          //Only Admin can edit closed product
          if(oldPC.EndDate__c < datetime.now()){
            pc.EndDate__c.addError(System.Label.LAT_BR_PC_ErrorPermissionClosed);
          }
          // Affected fields validation
          if(oldPC.Net_Sales_Case__c != pc.Net_Sales_Case__c || oldPC.UF__c != pc.UF__c || oldPC.StartDate__c != pc.StartDate__c || oldPC.Product__c != pc.Product__c || oldPC.AN8__c != pc.AN8__c || oldPC.Canal__c != pc.Canal__c || oldPC.CM_Case__c != pc.CM_Case__c || oldPC.DistributorCost__c != pc.DistributorCost__c || oldPC.LDCost__c != pc.LDCost__c  ){
            pc.addError(System.Label.LAT_BR_PC_ErrorPermissionEndDate);
          }
        }
      }
    }

  } else if (Trigger.isInsert) {
      for ( LAT_ProductCost__c pc : trigger.new ) {
            pc.EndDate__c = Datetime.newInstance(Date.newInstance(2050, 12, 31), Time.newInstance(23, 59, 59, 500));
            Integer y = Integer.valueOf(pc.Start_Year__c);
            Integer m = Integer.valueOf(pc.Start_Month__c);
            pc.StartDate__c =  Datetime.newInstance(Date.newInstance(y, m, 1),Time.newInstance(00, 1, 1, 100));
      }
  }



  /*
  * canUpdate
  * Check the user profile and return 2 booleans, canUpdate and IsAdmin
  * @return  List<Boolean>
  */
  public static List<Boolean> canUpdate(){

    List<Boolean> returnList = new List<Boolean>{false, false};
		User currentUser = [Select id,Profile.Name from User where id =: userinfo.getUserId()][0];
		String[] profileNames = LAT_GeneralConfigDao.getValueAsStringArray('LAT_PROFILE_UPDATE_PRODUCTCOST', ',');
    String[] adminNames = LAT_GeneralConfigDao.getValueAsStringArray('Admin', ',');
    if(profileNames != null){
      	for(String pn : profileNames){
          // Can Update
      		if(pn == currentUser.Profile.Name)returnList.set(0,true);
      	}
    }
    if(adminNames != null){
      	for(String pn : adminNames){
          // Can Update and is Admin
      		if(pn == currentUser.Profile.Name){
              returnList.set(0,true);
              returnList.set(1,true);
          }
      	}
    }
    return returnList;
	}

}