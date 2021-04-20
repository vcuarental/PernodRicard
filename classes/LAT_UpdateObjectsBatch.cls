/***************************************************************************
*   Company:Valuenet   Developers: Elena Schwarzböck   Date:26/02/2014     *
****************************************************************************/

global class LAT_UpdateObjectsBatch implements Database.Batchable<sObject> {
   
   global final String Query;   

   global LAT_UpdateObjectsBatch (String q) {
        Query=q;
   }

   global Database.QueryLocator start(Database.BatchableContext BC) {
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope) {
                   
      List<DataBase.SaveResult> scopeSR = DataBase.update(scope, false);
      
      //TODO: Trabajar los errores.
   
   }

   global void finish(Database.BatchableContext BC) {

   }

}