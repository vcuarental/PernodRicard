/************************************************************************************
*                           Company: ValueNet                                       *
*-----------------------------------------------------------------------------------*
*   Metodo de interfaz para actualizacion de clientes para Mexico                   *
************************************************************************************/

public with sharing class LAT_MX_WS01_CustomerHandlerReturn {
	
	public static String updateClientByAN8(LAT_WS01_CustomerHandlerReturn.Customer customer){
		Account acc;
		try{acc = [SELECT Id, Rating FROM Account WHERE Client_country_AN8__c =: (customer.country+'-'+customer.customer_AN8) LIMIT 1];}catch(Exception e){}
		
		if(acc == null){
			return LAT_WS01_CustomerHandlerReturn.notfound_Client;
		}
		
		//Mapeo de campos del cliente
		acc.Rating = customer.credCollStatus.trim();
		
		try{
			update acc;
		}catch(Exception e){
			return e.getMessage();
		}
		return LAT_WS01_CustomerHandlerReturn.success;
	}
	
}