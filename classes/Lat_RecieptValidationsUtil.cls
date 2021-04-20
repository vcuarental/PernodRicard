/*************************************************************************************************
*           Company: Zimmic    Developer: Mauricio Diaz    Date: 01/4/2016
*-------------------------------------------------------------------------------
*  This Class should have every validation of Reciepts (Prints) from AR to avoid any operations over Deposits, Compprobantes, etc such as delete, update 
*  
**************************************************************************************************/


public with sharing class Lat_RecieptValidationsUtil {

	public static final String RECIEPT_PRINT_PENDING = 'Receipt printed Deposit pending';
	public static final String RECIEPT_PRINT_DONE = 'Receipt printed Deposit done';
	public static final String RECIEPT_TREASAURY = 'Receipt Sent to Treasury';
	/*
	* @descp: this method will check for Reciepts already Print, we will compare agaisnt picklist value from ReceiptNo_AR__r.Status_AR__c
	*
	**/
	public static Boolean checkBothStatus(String statusRecieptValue){
		return (statusRecieptValue.equals(RECIEPT_PRINT_DONE) 
				|| statusRecieptValue.equals(RECIEPT_PRINT_PENDING)
				|| statusRecieptValue.equals(RECIEPT_TREASAURY));
	}
 

	public static Boolean allowUpdate(){
		User currentUser = [Select id,Profile.Name from User where id =: userinfo.getUserId()][0];
		String[] profileNames = LAT_GeneralConfigDao.getValueAsStringArray('AR_PROFILE_UPDATE_DEPOSITS', ',');
        Boolean containsProfileName = false;
        if(profileNames != null){
        	for(String pn : profileNames){
        		if(pn == currentUser.Profile.Name)return true;
        	}
        }
        return false;
	}



}