public with sharing class ASI_MFM_TH_GenPOItemsController {  
  ASI_MFM_PO__c po = new ASI_MFM_PO__c();

  public ASI_MFM_TH_GenPOItemsController(apexpages.standardController sc) {
    po = [select ASI_MFM_Plan__c, ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c, ASI_MFM_PO_Raised_Date__c,ASI_MFM_PO_Start_Date__c,ASI_MFM_PO_End_Date__c from ASI_MFM_PO__c where id = :sc.getId()];
  }

    public string buildPlanItemSoql() {
        string qs = 'select ';      
        boolean start = true;
        for (string f:schema.sobjectType.ASI_MFM_Plan_Line_Item__c.fields.getMap().keySet()) {
            if (start) {
                qs = qs + f;
                start = false;
            }
            else {
                qs = qs + ', ' + f;
            }
        }
        qs = qs + ' , ASI_MFM_Plan__r.ASI_MFM_Start_Date__c, ASI_MFM_Plan__r.ASI_MFM_End_Date__c from ASI_MFM_Plan_Line_Item__c where ASI_MFM_Plan__c = :po_id';
        return qs;
    }
  
  public pageReference genPOItems() {
      string mode = apexpages.currentPage().getParameters().get('mode');  
      id po_id = po.ASI_MFM_Plan__c;
      list<ASI_MFM_Plan_Line_Item__c> pni_list = database.query(buildPlanItemSoql());
      list<ASI_MFM_PO_Line_Item__c> poi_list = new list<ASI_MFM_PO_Line_Item__c>();
      map<string, id> rt_map = ASI_MFM_Function.getRecordTypeId('ASI_MFM_PO_Line_Item__c');
      for (ASI_MFM_Plan_Line_Item__c pni:pni_list) {
               
          if (mode == 'full') {
              
              if (po.ASI_MFM_PO_End_Date__c != pni_list[0].ASI_MFM_Plan__r.ASI_MFM_End_Date__c || po.ASI_MFM_PO_Start_Date__c != pni_list[0].ASI_MFM_Plan__r.ASI_MFM_Start_Date__c ){
                  apexpages.addMessage(new apexpages.Message(apexpages.severity.error, 'PO Start/End Date should be the same with Plan Start/End Date.'));
                  return null;
              }
              
              List<Decimal> PlanAmount= new List<Decimal>();
              List<Date> gldate= new List<Date>();
              //Get Today
              Date Nowday =  Date.today(); 
              Date firstDate = Nowday.toStartOfMonth();  //Get the first day of today's month 
              //Date Lastmonthday =firstDate.addDays(date.daysInMonth(Nowday.year() , Nowday.month())  - 1);
              
              Date Endd =po.ASI_MFM_PO_End_Date__c;
              Date firstEndDateS = Endd.toStartOfMonth(); 
              Date Lastmonthday =firstEndDateS.addDays(date.daysInMonth(Endd.year() , Endd.month())  - 1);
              
              //Start Day
              Date startday =po.ASI_MFM_PO_Start_Date__c;
              Date firstDateS = startday.toStartOfMonth();  //Get the first day of today's month 
              Date StartLMD =firstDateS.addDays(date.daysInMonth(startday.year() , startday.month())  - 1); //Lastmonthday
              String FY = po.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c;
              Integer startyear = 2000 + Integer.valueOf(po.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c.substring(2,4));
              Integer Endyear = 2001 + Integer.valueOf(po.ASI_MFM_Prefix__r.ASI_MFM_Fiscal_year__c.substring(2,4));
              if(pni.ASI_MFM_Month_1_Cost__c!=null){//JUL
                  PlanAmount.add(pni.ASI_MFM_Month_1_Cost__c);
                  Date temp = Date.newInstance(startyear, 7, 31);
                  if(po.ASI_MFM_PO_Start_Date__c<temp && po.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(po.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
                  
              }
              if(pni.ASI_MFM_Month_2_Cost__c!=null){//Aug
                  PlanAmount.add(pni.ASI_MFM_Month_2_Cost__c);
                  Date temp = Date.newInstance(startyear, 8, 31);
                  if(po.ASI_MFM_PO_Start_Date__c<temp && po.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(po.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_3_Cost__c!=null){//SEP
                  PlanAmount.add(pni.ASI_MFM_Month_3_Cost__c);
                  Date temp = Date.newInstance(startyear, 9, 30);
                  if(po.ASI_MFM_PO_Start_Date__c<temp && po.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(po.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_4_Cost__c!=null){//OCT
                  PlanAmount.add(pni.ASI_MFM_Month_4_Cost__c);
                  Date temp = Date.newInstance(startyear, 10, 31);
                  if(po.ASI_MFM_PO_Start_Date__c<temp && po.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(po.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_5_Cost__c!=null){//NOV
                  PlanAmount.add(pni.ASI_MFM_Month_5_Cost__c);
                  Date temp = Date.newInstance(startyear, 11, 30);
                  if(po.ASI_MFM_PO_Start_Date__c<temp && po.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(po.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_6_Cost__c!=null){//DEC
                  PlanAmount.add(pni.ASI_MFM_Month_6_Cost__c);
                  Date temp = Date.newInstance(startyear, 12, 31);
                  if(po.ASI_MFM_PO_Start_Date__c<temp && po.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(po.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_7_Cost__c!=null){//JAN
                  PlanAmount.add(pni.ASI_MFM_Month_7_Cost__c);
                  Date temp = Date.newInstance(Endyear, 1, 31);
                  if(po.ASI_MFM_PO_Start_Date__c<temp && po.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(po.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_8_Cost__c!=null){//FEB
                  PlanAmount.add(pni.ASI_MFM_Month_8_Cost__c);
                  Date temp = Date.newInstance(Endyear, 2, 28);
                  if(po.ASI_MFM_PO_Start_Date__c<temp && po.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(po.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_9_Cost__c!=null){//MAR
                  PlanAmount.add(pni.ASI_MFM_Month_9_Cost__c);
                  Date temp = Date.newInstance(Endyear, 3, 31);
                  if(po.ASI_MFM_PO_Start_Date__c<temp && po.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(po.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_10_Cost__c!=null){//APR
                  PlanAmount.add(pni.ASI_MFM_Month_10_Cost__c);
                  Date temp = Date.newInstance(Endyear, 4, 30);
                  if(po.ASI_MFM_PO_Start_Date__c<temp && po.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(po.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_11_Cost__c!=null){//MAY
                  PlanAmount.add(pni.ASI_MFM_Month_11_Cost__c);
                  Date temp = Date.newInstance(Endyear, 5, 31);
                  if(po.ASI_MFM_PO_Start_Date__c<temp && po.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(po.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              if(pni.ASI_MFM_Month_12_Cost__c!=null){//JUN
                  PlanAmount.add(pni.ASI_MFM_Month_12_Cost__c);
                  Date temp = Date.newInstance(Endyear, 6, 30);
                  if(po.ASI_MFM_PO_Start_Date__c<temp && po.ASI_MFM_PO_End_Date__c> temp){
                      gldate.add(temp);
                  }else if(po.ASI_MFM_PO_Start_Date__c<temp) {
                      gldate.add(Lastmonthday);
                  }else{
                      gldate.add(StartLMD);
                  }
              }
              
              for(Integer CountN = 0; CountN < PlanAmount.size(); CountN++){
                  ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c();
                  poi.ASI_MFM_A_C_Code__c = pni.ASI_MFM_A_C_Code__c;
                  poi.ASI_MFM_AP_Code__c = pni.ASI_MFM_AP_Code__c;
                  poi.ASI_MFM_BU_Code__c = pni.ASI_MFM_BU_Code__c;
                  poi.ASI_MFM_customer_name__c = pni.ASI_MFM_customer_name__c;
                  
                  poi.ASI_MFM_TH_Region__c = pni.ASI_MFM_TH_Region__c;
                  poi.ASI_MFM_PO__c = po.id;
                  poi.ASI_MFM_Sub_brand_Code__c = pni.ASI_MFM_Sub_brand_Code__c;
                  poi.ASI_MFM_List_Item_Description__c = pni.ASI_MFM_List_Item_Description__c; 
                  
                  
                  poi.ASI_MFM_G_L_Date__c = gldate[CountN];
                  
                  //add amount
                  poi.ASI_MFM_Amount__c = PlanAmount[CountN];
                  //poi.ASI_MFM_Original_Amount__c = pni.ASI_MFM_Original_Total_Cost__c; 
                  poi.recordTypeId = rt_map.get('ASI_MFM_TH_PO_Line_Item');
                  poi_list.add(poi);  
              }
              
          }else{
              ASI_MFM_PO_Line_Item__c poi = new ASI_MFM_PO_Line_Item__c();
              poi.ASI_MFM_A_C_Code__c = pni.ASI_MFM_A_C_Code__c;
              poi.ASI_MFM_AP_Code__c = pni.ASI_MFM_AP_Code__c;
              poi.ASI_MFM_BU_Code__c = pni.ASI_MFM_BU_Code__c;
              poi.ASI_MFM_customer_name__c = pni.ASI_MFM_customer_name__c;
              poi.ASI_MFM_G_L_Date__c = po.ASI_MFM_PO_Raised_Date__c;
              poi.ASI_MFM_TH_Region__c = pni.ASI_MFM_TH_Region__c;
              poi.ASI_MFM_PO__c = po.id;
              poi.ASI_MFM_Sub_brand_Code__c = pni.ASI_MFM_Sub_brand_Code__c;
              poi.ASI_MFM_List_Item_Description__c = pni.ASI_MFM_List_Item_Description__c; 
              poi.recordTypeId = rt_map.get('ASI_MFM_TH_PO_Line_Item');
              
              poi_list.add(poi);                 
          }
             
      }
      if (poi_list.size() > 0) {
          insert poi_list;
      }
      return new pageReference('/apex/ASI_MFM_TH_InputPOItemsPage?id=' + po.id);
  }
}