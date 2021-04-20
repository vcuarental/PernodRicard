/*******************************************************************************
*                           Company: ValueNet                                  *
*------------------------------------------------------------------------------*
*   Interfaz para la insercion/actualizacion de Oportunidades y sus Items      *
*******************************************************************************/

global class LAT_WS01_CustomerHandlerReturn {
        
    global class Customer{
        webservice Integer country;
        webservice Integer customer_AN8;
        webservice String credCollStatus;      
    }
    
    //Return codes
    public static String success             =  '0';
    public static String notFound_client     = '-1';

    webservice static String updateClientByAN8(Customer customer){

        String codeRet;
        String error;
        
        Savepoint sp = Database.setSavepoint();
        try{
            if(customer.Country==12){
                //Mexico
                codeRet = LAT_MX_WS01_CustomerHandlerReturn.updateClientByAN8(customer);
            }
        }catch(Exception e){
            Database.rollback(sp);
            error = e.getMessage();
            codeRet = e.getMessage();
        }    

        //DebugLog
        LAT_DebugUtil debug = new LAT_DebugUtil();
        debug.setOrigin('LAT_WS01_CustomerHandlerReturn');
        debug.addTitle('Parameters');
        debug.addData('Country', String.ValueOf(customer.country));
        debug.addData('Customer AN8', String.ValueOf(customer.customer_AN8));
        debug.addData('Status Credit and Collections', customer.credCollStatus);
        
        debug.setResult(codeRet);
        
        if(error != null){
            debug.addTitle('Error');
            debug.addData('error', error);
        }
        debug.insertDebug();
        
        return codeRet;
    }
   
}