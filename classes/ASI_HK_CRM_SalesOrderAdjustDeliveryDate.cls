public with sharing class ASI_HK_CRM_SalesOrderAdjustDeliveryDate extends ASI_HK_CRM_TriggerAbstract {
//Version 0.0.2
//Last modified: 20130815
//1.Change the api name of the custom setting.
//2.Comment the upper part 
//3.Totally change the logic of delivery Date
  private Time myUrgentDeliveryCutoffTimeGMT_1;
  private Time myUrgentDeliveryCutoffTimeGMT_2;
  public static Time testTime = null;

  //private Time cutOffTime = Time.newInstance(10, 0, 0, 0); 
  
  public ASI_HK_CRM_SalesOrderAdjustDeliveryDate() {
    super('ASI_HK_CRM_SalesOrderAdjustDeliveryDate');
  }
  
  public override void executeTriggerAction(TriggerAction tAction, List<sObject> sObjList, Map<ID, sObject> newMap, Map<ID, sObject> oldMap) {
    if ((tAction == TriggerAction.BEFORE_INSERT || tAction == TriggerAction.BEFORE_UPDATE)
      && !isBypassByCurrentUser()) {
      List<ASI_HK_CRM_Sales_Order__c> soList = (List<ASI_HK_CRM_Sales_Order__c>)sObjList;
      
      Time cutoffTimeGMT_1 = urgentDeliveryCutoffTimeGMT_1();
      Time cutoffTimeGMT_2 = urgentDeliveryCutoffTimeGMT_2();
      
      for (ASI_HK_CRM_Sales_Order__c so : soList) {
        System.debug('yeah1');
        
        Boolean boolValue = so.ASI_HK_CRM_Order_Date__c > so.ASI_HK_CRM_Delivery_Date__c;
        System.debug('Adjustcdjp1 operation boolValue ' + boolValue);
        System.debug('Adjustcdjp4 Order Date ' + so.ASI_HK_CRM_Order_Date__c);
        System.debug('Adjustcdjp5 Delivery Date ' + so.ASI_HK_CRM_Delivery_Date__c);
    
    if (boolValue)
      so.ASI_HK_CRM_Delivery_Date__c.adderror('The delivery date must greater than or equal to order date');
        
        if((so.ASI_HK_CRM_Order_Status_Name__c == 'Draft'  || so.ASI_HK_CRM_Order_Status_Name__c == 'Submitted') && !so.ASI_HK_CRM_Customize_Delivery_Date__c){
          System.debug('yeah2');
            ASI_HK_CRM_Sales_Order__c oldSO = tAction == TriggerAction.BEFORE_UPDATE ? (ASI_HK_CRM_Sales_Order__c)oldMap.get(so.Id) : null;
            if (oldSo != null){  
               System.debug('yeah3');
               if(oldSO.ASI_HK_CRM_Order_Date__c == so.ASI_HK_CRM_Order_Date__c 
               && oldSo.ASI_HK_CRM_Delivery_Date__c == so.ASI_HK_CRM_Delivery_Date__c
               && oldSo.ASI_HK_CRM_Urgent_Order__c == so.ASI_HK_CRM_Urgent_Order__c
               && oldSo.ASI_HK_CRM_Customize_Delivery_Date__c == so.ASI_HK_CRM_Customize_Delivery_Date__c)    
               return;
               System.debug('yeah4');
                
             }
     System.debug('yeah5');
 
          DateTime currentDateTime = Datetime.now();
          //currentTime = currentTime.addHours(8);   
          Date minDeliveryDate = currentDateTime.date();        
          Date currentDate = currentDateTime.date();
          Date userFillDeliveryDate = so.ASI_HK_CRM_Delivery_Date__c;
          Time currentTime = currentDateTime.time();
          currentTime = testTime == null? currentDateTime.time() : testTime;
          
          System.debug('key1 current Date'+currentDate);
          
          System.debug('key2 current time'+currentTime);
          System.debug('key3 cutOff1-'+myUrgentDeliveryCutoffTimeGMT_1);
          System.debug('key4 cutOff2-'+myUrgentDeliveryCutoffTimeGMT_2);
          System.debug('key5'+(currentTime > myUrgentDeliveryCutoffTimeGMT_1));
          System.debug('key5.1'+(currentTime > myUrgentDeliveryCutoffTimeGMT_2));
          
          Integer numDay;
          if(userFillDeliveryDate != null){          
            numDay = currentDate.daysBetween(userFillDeliveryDate);
          }
          System.debug('key5.2'+numDay);
          
          //Urgent Order = True, Delivery Date != null
          if (so.ASI_HK_CRM_Urgent_Order__c == true && userFillDeliveryDate != null){
              System.debug('key6');
              //Delivery Date = Today Before 10
              if (numDay == 0 && currentTime < myUrgentDeliveryCutoffTimeGMT_1){
                System.debug('key7');
                //Trigger Rule
              }
              
              //Delivery Date = Today After 10 before 1630
              else if(numDay == 0 && currentTime <  myUrgentDeliveryCutoffTimeGMT_2 && currentTime > myUrgentDeliveryCutoffTimeGMT_1){
                System.debug('key8');
                minDeliveryDate = minDeliveryDate.addDays(1);
                so.ASI_HK_CRM_Urgent_Order__c = false;          
              }
              
              //Delivery Date = Today after 1630
              else if(numDay == 0 && currentTime > myUrgentDeliveryCutoffTimeGMT_2){
                System.debug('key9');
                minDeliveryDate = minDeliveryDate.addDays(1);
              }
              
              //Delivery Date = Today + 1 Before 10
              else if(numDay == 1 && currentTime < myUrgentDeliveryCutoffTimeGMT_1){
                System.debug('key10');
                minDeliveryDate = minDeliveryDate;
                //Trigger Rule
              }
              
              //DeliveryDate = Today + 1 After 10 before 1630
              else if(numDay == 1 && currentTime > myUrgentDeliveryCutoffTimeGMT_1 && currentTime < myUrgentDeliveryCutoffTimeGMT_2){
                System.debug('key11');
                so.ASI_HK_CRM_Urgent_Order__c = false;
                minDeliveryDate = userFillDeliveryDate;
              }
              
              //DeliveryDate = Today + 1 After 0430 Do nothing
              else if(numDay == 1 && currentTime > myUrgentDeliveryCutoffTimeGMT_2){
                minDeliveryDate = userFillDeliveryDate;
              }
              
              //DeliveryDate = Today + N before 10
              else if (numDay > 1 &&  currentTime < myUrgentDeliveryCutoffTimeGMT_1){
                System.debug('key12');
                minDeliveryDate = minDeliveryDate; 
                //Trigger Rule
              }
              
              //DeliveryDate = Today + N after 10 before 1630
              else if(numDay > 1 &&  currentTime > myUrgentDeliveryCutoffTimeGMT_1 && currentTime < myUrgentDeliveryCutoffTimeGMT_2){
                System.debug('key13');
                minDeliveryDate = minDeliveryDate.addDays(1);
                so.ASI_HK_CRM_Urgent_Order__c = false;      
              }
              
              //DeliveryDate = Today + N after 1630
              else if(numDay > 1 && currentTime > myUrgentDeliveryCutoffTimeGMT_2){
                System.debug('key14');
                minDeliveryDate = minDeliveryDate.addDays(1);
              }
              
              //Other Case
              else {
                System.debug('key14.1');
                minDeliveryDate = userFillDeliveryDate;
              } 
          }
          //Urgent Order = false    
          else if(so.ASI_HK_CRM_Urgent_Order__c == false && userFillDeliveryDate != null){
              //Delivery Date = Today Before 10 Validation Rule Only              
              //Delivery Date = Today After 10 before 1630 Validate Rule Only             
              //Delivery Date = Today after 1630 Validation Rule Only             
              //Delivery Date = Today + 1 Before 10 Do nothing
              //Delivery Date = Today + 1 after 1630 before 1000
              System.debug('key15');
              System.debug('key15.1'+(numDay == 1));
              System.debug('key15.2'+(currentTime > myUrgentDeliveryCutoffTimeGMT_2));
              System.debug('key15.3'+numDay);
              //DeliveryDate = Today + 1 After 1630
              if(numDay == 0 && currentTime < myUrgentDeliveryCutoffTimeGMT_1){
                minDeliveryDate = minDeliveryDate.addDays(1);
              }
              else if(numDay == 1 && currentTime > myUrgentDeliveryCutoffTimeGMT_2){
                System.debug('key16'+minDeliveryDate);
                minDeliveryDate = userFillDeliveryDate.addDays(1);
                System.debug('key16.1'+minDeliveryDate);
                //so.ASI_HK_CRM_Urgent_Order__c = true;
              }
              else if(numDay > 1){
                System.debug('key16.2');
                minDeliveryDate = userFillDeliveryDate;
              }
              else if(numDay == 1 && currentTime < myUrgentDeliveryCutoffTimeGMT_2 && currentTime > myUrgentDeliveryCutoffTimeGMT_1){
                System.debug('key16.3');
                minDeliveryDate = userFillDeliveryDate;
              }
                
              //DeliveryDate = Today + N before 10 Do nothing
              //DeliveryDate = Today + N after 10 before 1630 Do nothing
              //DeliveryDate = Today + N after 1630 Do nothing  
              else {
                System.debug('key16.4');
                minDeliveryDate = userFillDeliveryDate;
              }
            
          }
          //Urgent Order is true, DeliveryDate null Value
          else if(userFillDeliveryDate == null){
             System.debug('key17');
             //Urgent Order is true
             if(so.ASI_HK_CRM_Urgent_Order__c == true){
                System.debug('key18');
                //Before 1000
                if(currentTime < myUrgentDeliveryCutoffTimeGMT_1){
                    System.debug('key19');
                    minDeliveryDate = minDeliveryDate;
                }
                
                //After 1000 before 1630
                else if(currentTime > myUrgentDeliveryCutoffTimeGMT_1 && currentTime < myUrgentDeliveryCutoffTimeGMT_2){
                    System.debug('key20');
                    minDeliveryDate = minDeliveryDate.addDays(1);
                    so.ASI_HK_CRM_Urgent_Order__c = false;
                }
                
                else if(currentTime > myUrgentDeliveryCutoffTimeGMT_2){
                    System.debug('key21');
                    minDeliveryDate = minDeliveryDate.addDays(1);
                }
                
             }
             else{//Urgent Order is false, Delivery Date null
                System.debug('key22');
                //Before 1000
                if(currentTime < myUrgentDeliveryCutoffTimeGMT_1){
                    System.debug('key23');
                    minDeliveryDate = minDeliveryDate.addDays(1);
                }               
                //After 1000 before 1630
                else if(currentTime > myUrgentDeliveryCutoffTimeGMT_1 && currentTime < myUrgentDeliveryCutoffTimeGMT_2){
                    System.debug('key24');
                    minDeliveryDate = minDeliveryDate.addDays(1);
                }
                //After 1630
                else if(currentTime > myUrgentDeliveryCutoffTimeGMT_2){
                    System.debug('key25');
                    minDeliveryDate = minDeliveryDate.addDays(2);
                }                                   
             }
          }       
          
          System.debug('key26'+minDeliveryDate);
          so.ASI_HK_CRM_Delivery_Date__c = minDeliveryDate;
        }
        
      }
    }
  }
  
  //Get the DeliveryCutOffTimeGMT from CustomSetting and turn to string
  private Time urgentDeliveryCutoffTimeGMT_1() {
    if (myUrgentDeliveryCutoffTimeGMT_1 == null) {
      ASI_HK_CRM_ThresholdValues__c thresholdValueSetting = ASI_HK_CRM_ThresholdValues__c.getOrgDefaults();
      if (thresholdValueSetting != null) {
        myUrgentDeliveryCutoffTimeGMT_1 = strToTime(thresholdValueSetting.ASI_HK_CRM_SO_Urgent_Cutoff_Time_1__c);
      }
    } 
    return myUrgentDeliveryCutoffTimeGMT_1;
  }

  
  private Time urgentDeliveryCutoffTimeGMT_2() {
    if (myUrgentDeliveryCutoffTimeGMT_2 == null) {
      ASI_HK_CRM_ThresholdValues__c thresholdValueSetting = ASI_HK_CRM_ThresholdValues__c.getOrgDefaults();
      if (thresholdValueSetting != null) {
        myUrgentDeliveryCutoffTimeGMT_2 = strToTime(thresholdValueSetting.ASI_HK_CRM_SO_Urgent_Cutoff_Time_2__c);
      }
    } 
    return myUrgentDeliveryCutoffTimeGMT_1;
  }
    
  private Time strToTime(String timeStr) {
    try {
      if (timeStr != null && timeStr.trim() != '') {
        List<String> timeElements = timeStr.trim().split(':', 0);
        Integer numOfTimeEle = timeElements.size();
        if (numOfTimeEle > 3 || numOfTimeEle <= 0) throw new ASI_HK_CRM_CustomException();
        for (String timeEle : timeElements) {
          if (!timeEle.trim().isNumeric())
            throw new ASI_HK_CRM_CustomException();
        }
        Integer hour = 0, minute = 0, second = 0, millisecond = 0;
        if (numOfTimeEle >= 1) hour = Integer.valueOf(timeElements[0].trim());
        if (numOfTimeEle >= 2) minute = Integer.valueOf(timeElements[1].trim());
        if (numOfTimeEle == 3) second = Integer.valueOf(timeElements[2].trim());
        return Time.newInstance(hour, minute, second, millisecond);
      }
    } catch (Exception e) {
      throw new ASI_HK_CRM_CustomException('Invalid time string in custom setting');
    }
    return null;
  }
  


}