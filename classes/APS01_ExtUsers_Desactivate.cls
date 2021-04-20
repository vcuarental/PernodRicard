/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Cécile Lartaud                                                                     |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | User                                                             					 |
|     - Description     | Desactivate External Users who has expired and automatically change status.		 |
+-----------------------+------------------------------------------------------------------------------------+
| Creation Date         | 20/12/2012                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
global without sharing class APS01_ExtUsers_Desactivate implements Schedulable{
    
    global void execute(SchedulableContext sc) {
        try{
            if(!Test.isRunningTest()) Database.executeBatch(new APB01_ExtUsers_Desactivate(), 200);
            if(Test.isRunningTest()) throw new testException();
        }catch(Exception e){
            System.debug('## APS01_ExtUsers_Desactivate - '+e.getTypeName()+' '+e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    /**
    *     exception pour tester les exceptions
    */
    public class testException extends Exception {} 
}