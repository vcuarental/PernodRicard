/**********************************************************************************
 * Name : ASI_KOR_KeymanAllocationBatch 
 * Created : Vincent Lam
 * Version History
 * Date             Developer               Comments
 * ---------------  --------------------    --------------------------------------------------------------------------------
 * 2017-08-02		Laputa: Vincent			Create
 **********************************************************************************/

global class ASI_KOR_KeymanAllocationBatch 
    implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
        
        public string yearStr;  
        public string monthStr;  
		public string region;
		public ASI_KOR_RSD_Payment_Settlement_Header__c rsdPS;
		public list<string> list_owner;
		public list<string> list_paymentID;
	public Map<Id, Set<String>> rsdPaySetSendMap;
	public List<String> list_TMKTemail;

    public ASI_KOR_KeymanAllocationBatch (String yearStr, String monthStr, String region, ASI_KOR_RSD_Payment_Settlement_Header__c rsdPS, Map<Id, Set<String>> rsdPaySetSendMap, List<String> list_TMKTemail) {
        this.yearStr = yearStr;
        this.monthStr = monthStr;
		this.region = region;
		this.rsdPS = rsdPS;
		this.rsdPaySetSendMap = rsdPaySetSendMap;
		this.list_TMKTemail = list_TMKTemail;
		this.list_owner = new list<string>();
		this.list_paymentID = new list<string>();
		for (ASI_KOR_SR_Payment_Settlement_Header__c payment : [
			select id, ownerid
			from ASI_KOR_SR_Payment_Settlement_Header__c
			where ASI_KOR_Year__c = :yearStr
            and ASI_KOR_Month__c = :monthStr
            and ASI_KOR_Region__c = :region
		]){
			this.list_owner.add(payment.ownerid);
			this.list_paymentID.add(payment.id);
		}
    }                                            
    
    global database.querylocator start(Database.BatchableContext BC){
        // This methods returns a SOQL query locator containing the records
        return Database.getQueryLocator([
			select id,
			ASI_KOR_Venue__c,
			ASI_KOR_Item_Group__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__c,
			ASI_KOR_UOM__c,
			ASI_KOR_Quantity_Bottle__c,
			ASI_KOR_Quantity_Case__c,
			ASI_KOR_Keyman__c
			from ASI_KOR_VMS_Interface_File__c
			where ASI_KOR_Venue__r.ownerid in :list_owner
			and ASI_KOR_Promotion_Year__c = :yearStr
			and ASI_KOR_Promotion_Month__c = :monthStr
		]);
    }
 
    global void execute(Database.BatchableContext contextInstance, List<sObject> pLstFetchedRecords) {
        
		List<ASI_KOR_VMS_Interface_File__c> list_VMS = (List<ASI_KOR_VMS_Interface_File__c>) pLstFetchedRecords;
		
		set<string> set_venueID = getVenueID(list_VMS);		
		map<string, ASI_KOR_SR_Payment_Settlement_Detail__c> map_venueBrand_finalVI = getPayment(set_venueID, this.list_paymentID);
		map<string, string> map_venueID_wholesalerCode = getWholesaler(set_venueID);
		List<ASI_KOR_VMS_Interface_File__c> list_VMSToUpdate = populateVMS(list_VMS, map_venueBrand_finalVI, map_venueID_wholesalerCode);
		
		if (list_VMSToUpdate.size()>0) update list_VMSToUpdate;
    }
           
        
    public void execute(SchedulableContext contextInstance) {}

    // do the final proposal data update / insert in finish
	global void finish(Database.BatchableContext contextInstance) {
		try {
			String subject = 'Trade Spend Cycle Start Notification – Keyman Allocation - ' + rsdPS.ASI_KOR_Region__c;

			String mailingMessage  = 'Trade Spend Cycle Start Notification – Keyman Allocation'+'\r\n\r\n';
			mailingMessage  += 'Region: '  + rsdPS.ASI_KOR_Region__c + '\r\n';
			mailingMessage  += 'Year: '  + rsdPS.ASI_KOR_Year__c + '\r\n';
			mailingMessage  += 'Month: '  + rsdPS.ASI_KOR_Month__c +  '\r\n';
			mailingMessage  += '\r\n';
			mailingMessage  += 'Now you can start your process for Keyman Allocation.'+  '\r\n\r\n';
			mailingMessage  += 'Thanks.'+  '\r\n\r\n';

			List<String> toAddresses = new List<String>(rsdPaySetSendMap.get(rsdPS.Id));
			toAddresses.add('prasia.mobile@pernod-ricard.com');

			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setToAddresses(toAddresses);
			email.setCcAddresses(list_TMKTemail);
			email.setSubject(subject);
			email.setPlainTextBody(mailingMessage);
			email.setSaveAsActivity(false);

			Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
			System.debug('Email sent successfully :' + email);
		} catch (Exception e) {
			ApexPages.Message err = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
			ApexPages.addMessage(err);
		}
	}
       
	public set<string> getVenueID(List<ASI_KOR_VMS_Interface_File__c> list_VMS){
		set<string> set_venueID = new set<string>();
		for (ASI_KOR_VMS_Interface_File__c vms : list_VMS){
			set_venueID.add(vms.ASI_KOR_Venue__c);
		}
		return set_venueID;
	}
	
	public map<string, ASI_KOR_SR_Payment_Settlement_Detail__c> getPayment(set<string> set_venueID, list<string> list_paymentID){
		map<string, ASI_KOR_SR_Payment_Settlement_Detail__c> map_venueBrand_finalVI = new map<string, ASI_KOR_SR_Payment_Settlement_Detail__c>();
		for(ASI_KOR_SR_Payment_Settlement_Detail__c payment : [
			select id, 
			ASI_KOR_Brand__c, 
			ASI_KOR_Final_Basic_Amount__c,
			ASI_KOR_Actual_Volume__c,
			ASI_KOR_Venue_Name__c
			from ASI_KOR_SR_Payment_Settlement_Detail__c
			where ASI_KOR_SR_Payment_Settlement__c in :list_paymentID
            and ASI_KOR_Venue_Name__c in :set_venueID
            and ASI_KOR_SR_Payment_Settlement__r.ASI_KOR_Status__c = 'Approved by BM'
			and ASI_KOR_Actual_Volume__c <> null
			and ASI_KOR_Actual_Volume__c <> 0
			and ASI_KOR_Final_Basic_Amount__c <> null
			and ASI_KOR_Final_Basic_Amount__c <> 0
		]){
			string key = payment.ASI_KOR_Venue_Name__c + '_' + payment.ASI_KOR_Brand__c;
			map_venueBrand_finalVI.put(key, payment);
		}
		return map_venueBrand_finalVI;
	} 
	
	public map<string, string> getWholesaler(set<string> set_venueID){
		map<string, string> map_venueID_wholesalerCode = new map<string, string>();
		for (ASI_KOR_Venue_Supplier__c supplier : [
			select id, 
			ASI_KOR_Wholesaler_Code__c, 
			ASI_KOR_Representative_WS__c,
			ASI_KOR_Venue_Supplier_To_Venue_Lookup__c
			from ASI_KOR_Venue_Supplier__c
			where ASI_KOR_Venue_Supplier_To_Venue_Lookup__c in :set_venueID
			order by ASI_KOR_Representative_WS__c desc
		]){
			string key = supplier.ASI_KOR_Venue_Supplier_To_Venue_Lookup__c;
			if (map_venueID_wholesalerCode.containsKey(key)){
				continue;
			} else {
				map_venueID_wholesalerCode.put(key, supplier.ASI_KOR_Wholesaler_Code__c);
			}
		}
		return map_venueID_wholesalerCode;
	}
	
	public list<ASI_KOR_VMS_Interface_File__c> populateVMS(
		list<ASI_KOR_VMS_Interface_File__c> list_VMS, 
		map<string, ASI_KOR_SR_Payment_Settlement_Detail__c> map_venueBrand_finalVI, 
		map<string, string> map_venueID_wholesalerCode
	){
		for (ASI_KOR_VMS_Interface_File__c vms : list_VMS){
			string key = vms.ASI_KOR_Venue__c + '_' + vms.ASI_KOR_Item_Group__r.ASI_KOR_Sub_Brand__r.ASI_KOR_Brand__c;
            string UOM = vms.ASI_KOR_UOM__c;
            decimal keymanVolume = UOM == 'C' ? vms.ASI_KOR_Quantity_Case__c : vms.ASI_KOR_Quantity_Bottle__c;
            keymanVolume = keymanVolume == null ? 0 : keymanVolume;
			vms.ASI_KOR_Actual_Volume__c = keymanVolume;
			if (map_venueBrand_finalVI.containsKey(key)){
				ASI_KOR_SR_Payment_Settlement_Detail__c payment = map_venueBrand_finalVI.get(key);
				decimal paymentVolume = payment.ASI_KOR_Actual_Volume__c;
				decimal paymentVI = payment.ASI_KOR_Final_Basic_Amount__c;
				decimal keymanVI = keymanVolume == 0 ? 0 : (paymentVI * keymanVolume / paymentVolume);
				vms.ASI_KOR_CA_Amount__c = keymanVI;
				vms.ASI_KOR_VI_Amount_Original__c = keymanVI;
				vms.ASI_KOR_Final_VI__c = paymentVI;
            } else {
                vms.ASI_KOR_CA_Amount__c = 0;
				vms.ASI_KOR_VI_Amount_Original__c = 0;
				vms.ASI_KOR_Final_VI__c = 0;
            }
			vms.ASI_KOR_Keyman_Original__c = vms.ASI_KOR_Keyman__c;
			if (map_venueID_wholesalerCode.containsKey(vms.ASI_KOR_Venue__c)){
				string wholesalerCode = map_venueID_wholesalerCode.get(vms.ASI_KOR_Venue__c);
				vms.ASI_KOR_WS_Code__c = wholesalerCode;
			}
		}
		return list_VMS;
	}
}