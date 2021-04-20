/**********************************************************************************
 * Name : ASI_KOR_CalPrevMonthsValue_Sche 
 * Created : Vincent Lam 
 * Revision History:
 * 1. 2017-07-12 - [VL 1.0] Created
 **********************************************************************************/

global class ASI_KOR_CalPrevMonthsValue_Sche implements Schedulable {

    global void execute(SchedulableContext sc) {

        Id jobId1 = Database.executeBatch(new ASI_KOR_CalPrevMonthsValueByDetail(), 20);
        System.debug('------ jobId ------ : ' + jobId1);
        Id jobId2 = Database.executeBatch(new ASI_KOR_CalPrevMonthsValueByBrand(), 20);
        System.debug('------ jobId ------ : ' + jobId2);

    }

}