/**********************************************************************************************************************************
                                                                                                                                      
    Developer: Francisco Orzabal                                                                                                   
    Created Date: 03/06/2014                                                                                                        
                                                                                                                                      
    Description: Se encarga de schedulear la clase LAT_BR_PCS01_ContractAccRatingBatch.

    Last Modified Date:                                                                                                                     
    Last Developer:                                                                                                   
    
    Versión:
    V1.0 - 03/06/2014 - Initial version [FO]
    
/**********************************************************************************************************************************/

global class LAT_BR_PCS01_ContractAccRatingSchedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        
        Date hoy = Date.today();
        Id IdRT = Global_RecordTypeCache.getRtId('AccountOn_Trade');
                        
        LAT_BR_PCS01_ContractAccRatingBatch car = new LAT_BR_PCS01_ContractAccRatingBatch(); 
        database.executebatch(car);
    
    }

}