/**********************************************
 Company: ValueNet
 Dev: Juan Pablo Cubo       Version: 1
 This trigger schedules a batch, only works with
 the first record of the trigger scope.
 Modified by: Elena J. Schwarzböck
**********************************************/

trigger LAT_CleanAccountProductPayment on LAT_Clean_Account_Product_Payment__c (after insert) {
    
    List<LAT_Clean_Account_Product_Payment__c> listcappToUpdate = new List<LAT_Clean_Account_Product_Payment__c>();
    
    for(LAT_Clean_Account_Product_Payment__c capp: trigger.new){
        LAT_Clean_Account_Product_Payment__c tt = new LAT_Clean_Account_Product_Payment__c(Id = capp.Id, LAT_Status__c = 'Pending');
        listcappToUpdate.add(tt); 
        DateTime nowTime = datetime.now().addSeconds(65);
        String Seconds = '0';
        String Minutes = String.valueOf(nowTime.minute()).length() == 1 ? '0' + String.valueOf(nowTime.minute()) : String.valueOf(nowTime.minute());
        String Hours = String.valueOf(nowTime.hour()).length() == 1 ? '0' + String.valueOf(nowTime.hour()) : String.valueOf(nowTime.hour());
        String DayOfMonth = String.valueOf(nowTime.day());
        String Month = String.ValueOf(nowTime.month());
        String DayOfweek = '?';
        String optionalYear = String.valueOf(nowTime.year());
        String CronExpression = Seconds+' '+Minutes+' '+Hours+' '+DayOfMonth+' '+Month+' '+DayOfweek+' '+optionalYear;
        
        LAT_CleanAccProductPaymentScheduler scheduleToRun = new LAT_CleanAccProductPaymentScheduler();
        scheduleToRun.idCAPP = capp.Id;      
        String idjob = system.schedule('LAT_CleanAccProductPaymentScheduler '+system.now(), CronExpression, scheduleToRun);
    }  
    
    DataBase.update(listcappToUpdate);
    
}