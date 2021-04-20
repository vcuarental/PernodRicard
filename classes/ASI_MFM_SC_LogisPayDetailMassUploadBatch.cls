global class ASI_MFM_SC_LogisPayDetailMassUploadBatch implements Database.Batchable<String>, Database.Stateful {

	//Global variable preserve in all batch
	global string errorMessage = '';
	global integer recordCount = 0;
	global integer recordParseCount = 0;
	global integer errRecordCount = 0;
	global boolean parseSuccess = true;
	global Map<string,integer> columnHeaderIndex = new Map<string,integer>();

	public final Blob content;
	public final Id ownerId,payheaderId;
	public string poHeaderName;
//    global List<String> badLines;
	public static final string RECORDTYPE_LINE_ITEM = 'ASI_MFM_Payment_Line_Item__cASI_MFM_SC_Payment_Line_Item';
	public static final string APNAME_DELIVERY_SEA 				= 'Shipping/Delivery - Sea';
	public static final string APNAME_DELIVERY_AIR 				= 'Shipping/Delivery - Air';
	public static final string APNAME_DELIVERY_TRUCK 			= 'Shipping/Delivery - Truck';
	public static final string APNAME_DUTY 						= 'Warehousing - Storage / Duty';
	public static final string APNAME_INTERSITE 				= 'Shipping/Delivery - Inter-site';
	public static final string APNAME_LABOUR_STAMPING 			= 'Warehousing - Labour Stamping';
	public static final string APNAME_LABOUR_REWORK 			= 'Warehousing - Labour Rework';
	public static final string APNAME_TRANSPORTATION_MATERIALS 	= 'Shipping/Delivery - Transp. Materials';
	public static final string APNAME_OTHER_LOGISTICS 			= 'Shipping/Delivery - Other cost';
	public static final string APNAME_DF_HAND 					= 'Accrued handling cost (D/F Handling)';
	public static final string APNAME_STORAGE 					= 'Warehousing - Storage / Duty';
	public static final string APNAME_POS_STORAGE 				= 'Warehousing - POS Storage';
	public static final string APNAME_OIE 						= 'Other income and expenses';
	public static final string APNAME_SUSPENSE 					= 'Suspense';
	public static final string APNAME_DAMAGE_WITH_PRODCODE 		= 'Breakage/Shortage (Damage)';

	//CSV file Column static name
	public static final string CNAME_BU = 'BU';
	public static final string CNAME_COST_CENTRE = 'cost centre';
	public static final string CNAME_CUSTOMER = 'Customer';
	public static final string CNAME_COUNTRY = 'Country';
	public static final string CNAME_JOB_TYPE = 'Job Type';

	public static final string CNAME_INV_DATE = 'Inv Date (YYYY-MM-DD)';
	public static final string CNAME_INVOICE_NO = 'Invoice No.';
	public static final string CNAME_JOB_NO = 'Job No';
	public static final string CNAME_CUSTOMER_NAME = 'Customer Name';
	public static final string CNAME_PO_NO = 'PO No';

	public static final string CNAME_D_F_DELIVERY_SEA = 'Shipping/Delivery - Sea';
	public static final string CNAME_D_F_DELIVERY_AIR = 'Shipping/Delivery - Air';
	public static final string CNAME_D_F_DELIVERY_TRUCK = 'Shipping/Delivery - Truck';
	public static final string CNAME_DUTY = 'Warehousing - Storage / Duty';
	public static final string CNAME_INTERSITE = 'Shipping/Delivery - Inter-site';

	public static final string CNAME_LABOUR_STAMPING = 'Warehousing - Labour Stamping';
	public static final string CNAME_LABOUR_REWORK = 'Warehousing - Labour Rework';
	public static final string CNAME_TRANSPORTATION_MATERIALS = 'Shipping/Delivery - Transp. Materials';
	public static final string CNAME_OTHER_LOGISTICS = 'Shipping/Delivery - Other cost';
	public static final string CNAME_D_F_HAND = 'Accrued handling cost (D/F Handling)';

	public static final string CNAME_STORAGE = 'Warehousing - Storage / Duty';
	public static final string CNAME_POS_STORAGE = 'Warehousing - POS Storage';
	public static final string CNAME_OIE = 'Other income and expenses';
	public static final string CNAME_SUSPENSE = 'Suspense';
	public static final string CNAME_REMARK_FOR_SUSPENSE = 'Remark for Suspense';

	public static final string CNAME_DAMAGED = 'Breakage/Shortage (Damage)';
	public static final string CNAME_GRAND_TOTAL = 'Grand Total';
	public static final string PAYMENT_LIST_ITEM_DESCRIPTION = 'Payment List Item Description';

	public ASI_MFM_SC_LogisPayDetailMassUploadBatch(){

	}

	public ASI_MFM_SC_LogisPayDetailMassUploadBatch(Blob content, Id ownerId, Id payheaderId,String poHeaderName) {
		this.content = content;
		this.ownerId = ownerId;
		this.payheaderId=payheaderId;
		this.poHeaderName=poHeaderName;
		System.debug('headerid='+payheaderId+','+poHeaderName)     ;
//        this.badLines = new List<String>();
	}

	/**
* Split a string of any size, while avoiding the dreaded 'Regex too complicated'
* error, which the String.split(String) method causes on some large inputs.
*
* Note that this method does not avoid other errors, such as those related to
* excess heap size or CPU time.
*/
	List<String> safeSplit(String inStr, String delim) {
		Integer regexFindLimit = 100;
		Integer regexFindCount = 0;

		List<String> output = new List<String>();

		Matcher m = Pattern.compile(delim).matcher(inStr);

		Integer lastEnd = 0;

		while (!m.hitEnd()) {
			while (regexFindCount < regexFindLimit && !m.hitEnd()) {
				if (m.find()) {
					output.add(inStr.substring(lastEnd, m.start()));
					lastEnd = m.end();
				} else {
					output.add(inStr.substring(lastEnd));
					lastEnd = inStr.length();
				}

				regexFindCount++;
			}

			// Note: Using region() to advance instead of substring() saves
			// drastically on heap size. Nonetheless, we still must reset the
			// (unmodified) input sequence to avoid a 'Regex too complicated'
			// error.
			m.reset(inStr);
			m.region(lastEnd, m.regionEnd());

			regexFindCount = 0;
		}

		return output;
	}

	public boolean badString(String s){
		if (String.isEmpty(s)) {
			return true;
		}
		List<String> values = s.split(',');
		if (values.size() < 11) {
			return true;
		}

		return false;
	}

	public List<String> start(Database.BatchableContext BC) {
		// This methods returns a SOQL query locator containing the records
		List<String> fileLines = safeSplit(this.content.toString(),'\n');

		columnHeaderIndex = createColumnMapping(fileLines[0].trim());

		fileLines.remove(0);

		return fileLines;
	}

	//This method will map the column header and return a zero base position of each column.
	//Mapping method: trim, upper case and start with same string
	public Map<string,integer> createColumnMapping(string titleLine){
		Map<string,integer> headerIndex = new Map<string,integer>();

		List<string> colkayList = new List<string>{CNAME_BU,CNAME_COST_CENTRE,CNAME_CUSTOMER,CNAME_COUNTRY,CNAME_JOB_TYPE,
				CNAME_INV_DATE,CNAME_INVOICE_NO,CNAME_JOB_NO,CNAME_CUSTOMER_NAME,CNAME_PO_NO,
				CNAME_D_F_DELIVERY_SEA,CNAME_D_F_DELIVERY_AIR,CNAME_D_F_DELIVERY_TRUCK,CNAME_DUTY,CNAME_INTERSITE,
				CNAME_LABOUR_STAMPING,CNAME_LABOUR_REWORK,CNAME_TRANSPORTATION_MATERIALS,CNAME_OTHER_LOGISTICS,CNAME_D_F_HAND,
				CNAME_STORAGE,CNAME_POS_STORAGE,CNAME_OIE,CNAME_SUSPENSE,CNAME_REMARK_FOR_SUSPENSE,
				CNAME_DAMAGED,CNAME_GRAND_TOTAL,PAYMENT_LIST_ITEM_DESCRIPTION};


		List<String> values = titleLine.split(',');
		integer colCount = 0;
		for(string s: values){
			integer kcount = 0;
			for(string k : colkayList){
				if(s.trim().toUpperCase().startsWith(k.trim().toUpperCase())){
					headerIndex.put(k,colCount);
					colkayList.remove(kcount);//reduce loop
					break;
				}
				kcount++;
			}
			colCount++;
		}
		system.debug('Column Header Mapping Index:');
		for(string s : headerIndex.keySet()){
			system.debug('>>>' + s + ';' + headerIndex.get(s));
		}
		return headerIndex;
	}

	// The executeBatch method is called for each chunk of records returned from start.
	public void execute(Database.BatchableContext BC, List<String> scope) {

		ASI_MFM_Payment__c payment = [select ASI_MFM_Sys_Error_Log__c from ASI_MFM_Payment__c where id =:payheaderId  limit 1 ];
		payment.ASI_MFM_Sys_Error_Log__c = null;
		update payment;

		List<String> fileLines = scope;

		for (String line : fileLines) {
//            possible empty line
			if (badString(line)) {
				continue;
			}
		}



		Map<String,Id> buM = new Map<String,Id>();
		Map<String,Id> buDesM = new Map<String,Id>();
		Map<Id,String> buNameM = new Map<Id,String>();
		Map<Id,String> buNameCodeM = new Map<Id,String>();
		for (asi_mfm_bu__c bu : [SELECT Id, name, ASI_MFM_BU_Mapping__c,ASI_MFM_BU_Code__c FROM asi_mfm_bu__c WHERE recordtype.name='SC BU' and ASI_MFM_Inactive__c = false and ASI_MFM_Is_Logsitic_BU__c = true]) {
			buDesM.put(bu.ASI_MFM_BU_Mapping__c, bu.id);//use desctiption as key to get id
			buNameM.put(bu.id, bu.name);//use Id as key to get Name
			buM.put(bu.name, bu.id);//use name as key to get ID
			buNameCodeM.put(bu.id, bu.ASI_MFM_BU_Code__c);//use Id as key to get BU Code
		}

		Map<String,Id> apM = new Map<String,Id>();
		Map<String,Id> apacM = new Map<String,Id>();
		for (asi_mfm_ap_code__c ap : [SELECT Id, name,ASI_MFM_A_C_Code__c FROM asi_mfm_ap_code__c WHERE recordtype.name='SC AP Code' and ASI_MFM_Inactive__c=false]) {
			apM.put(ap.name, ap.id);
			apacM.put(ap.name, ap.ASI_MFM_A_C_Code__c);
		}

		Map<String, Id> poDM1 = new Map<String, Id>();
		Map<String, Id> poDM2 = new Map<String, Id>();
		for (ASI_MFM_po_line_item__c pod : [SELECT Id,name,asi_mfm_bu_code__r.name, asi_mfm_ap_code__r.name FROM ASI_MFM_po_line_item__c WHERE recordtype.name ='SC PO Line Item' and asi_mfm_po__r.name = :poHeaderName]) {
			poDM1.put(pod.name, pod.id);
			system.debug('poDM1: '+ pod.name + ','+ pod.id);
			System.debug('poDM2 : ' + pod.asi_mfm_bu_code__r.name+'_'+pod.asi_mfm_ap_code__r.name);
			poDM2.put(pod.asi_mfm_bu_code__r.name+'_'+pod.asi_mfm_ap_code__r.name, pod.id);
		}
		system.debug(poDM1);
		system.debug(poDM2);


		Decimal poAmount = 0;
		List<ASI_MFM_PO__c> poList = [SELECT Id,ASI_MFM_PO_Amount__c FROM ASI_MFM_PO__c WHERE Name = :poHeaderName limit 1];
		if (poList.size() > 0)
			poAmount = poList[0].ASI_MFM_PO_Amount__c;

		Id payDrecordtype=Global_RecordTypeCache.getRtId(RECORDTYPE_LINE_ITEM);

		List<ASI_MFM_Payment_Line_Item__c> newPayDL = new List<ASI_MFM_Payment_Line_Item__c>();



		for (String line : fileLines) {

			System.debug('line : ' + line + ' is bad ? ' +  badString(line));
			//            possible empty line
			if (badString(line)) {
//                badLines.add(line);
				continue;
			}

			recordParseCount++;

			List<String> values = line.split(',');


			Map<String,Decimal> newPaymentAmount = new Map<String,Decimal>();
			/*    system.debug('D/F DELIVERY - SEA values[9] '+ values[9] + 'is numeric::'+ values[9].isNumeric());
				system.debug('D/F HANDLING - SEA values[10] '+ values[10]+ 'is numeric::'+ values[10].isNumeric());
				system.debug('OTHER LOGISTICS values[11] '+ values[11]+ 'is numeric::'+ values[11].isNumeric());*/
			try{
				//columnHeaderIndex
				//if(String.isNotBlank(values[10])) {
				if(String.isNotBlank(values[columnHeaderIndex.get(CNAME_D_F_DELIVERY_SEA)])) {
					//CNAME_D_F_DELIVERY_SEA
					newPaymentAmount.put(APNAME_DELIVERY_SEA, Decimal.valueof(values[columnHeaderIndex.get(CNAME_D_F_DELIVERY_SEA)].trim()));
				}
				if(String.isNotBlank(values[columnHeaderIndex.get(CNAME_D_F_DELIVERY_AIR)])) {
					//CNAME_D_F_DELIVERY_AIR
					newPaymentAmount.put(APNAME_DELIVERY_AIR, Decimal.valueof(values[columnHeaderIndex.get(CNAME_D_F_DELIVERY_AIR)].trim()));
				}
				if(String.isNotBlank(values[columnHeaderIndex.get(CNAME_D_F_DELIVERY_TRUCK)])) {
					//CNAME_D_F_DELIVERY_TRUCK
					newPaymentAmount.put(APNAME_DELIVERY_TRUCK, Decimal.valueof(values[columnHeaderIndex.get(CNAME_D_F_DELIVERY_TRUCK)].trim()));
				}
				if(String.isNotBlank(values[columnHeaderIndex.get(CNAME_DUTY)])) {
					//CNAME_DUTY
					newPaymentAmount.put(APNAME_DUTY, Decimal.valueof(values[columnHeaderIndex.get(CNAME_DUTY)].trim()));
				}
				if(String.isNotBlank(values[columnHeaderIndex.get(CNAME_INTERSITE)])) {
					//CNAME_INTERSITE
					newPaymentAmount.put(APNAME_INTERSITE, Decimal.valueof(values[columnHeaderIndex.get(CNAME_INTERSITE)].trim()));
				}
				if(String.isNotBlank(values[columnHeaderIndex.get(CNAME_LABOUR_STAMPING)])) {
					//CNAME_LABOUR_STAMPING
					newPaymentAmount.put(APNAME_LABOUR_STAMPING, Decimal.valueof(values[columnHeaderIndex.get(CNAME_LABOUR_STAMPING)].trim()));
				}
				if(String.isNotBlank(values[columnHeaderIndex.get(CNAME_LABOUR_REWORK)])) {
					//CNAME_LABOUR_REWORK
					newPaymentAmount.put(APNAME_LABOUR_REWORK, Decimal.valueof(values[columnHeaderIndex.get(CNAME_LABOUR_REWORK)].trim()));
				}
				if(String.isNotBlank(values[columnHeaderIndex.get(CNAME_TRANSPORTATION_MATERIALS)])) {
					//CNAME_TRANSPORTATION_MATERIALS
					newPaymentAmount.put(APNAME_TRANSPORTATION_MATERIALS, Decimal.valueof(values[columnHeaderIndex.get(CNAME_TRANSPORTATION_MATERIALS)].trim()));
				}
				if(String.isNotBlank(values[columnHeaderIndex.get(CNAME_OTHER_LOGISTICS)])) {
					//CNAME_OTHER_LOGISTICS
					newPaymentAmount.put(APNAME_OTHER_LOGISTICS, Decimal.valueof(values[columnHeaderIndex.get(CNAME_OTHER_LOGISTICS)].trim()));
				}
				if(String.isNotBlank(values[columnHeaderIndex.get(CNAME_D_F_HAND)])) {
					//CNAME_D_F_HAND
					newPaymentAmount.put(APNAME_DF_HAND, Decimal.valueof(values[columnHeaderIndex.get(CNAME_D_F_HAND)].trim()));
				}
				if(String.isNotBlank(values[columnHeaderIndex.get(CNAME_STORAGE)])) {
					//CNAME_STORAGE
					newPaymentAmount.put(APNAME_STORAGE, Decimal.valueof(values[columnHeaderIndex.get(CNAME_STORAGE)].trim()));
				}
				if(String.isNotBlank(values[columnHeaderIndex.get(CNAME_POS_STORAGE)])) {
					//CNAME_POS_STORAGE
					newPaymentAmount.put(APNAME_POS_STORAGE, Decimal.valueof(values[columnHeaderIndex.get(CNAME_POS_STORAGE)].trim()));
				}
				if(String.isNotBlank(values[columnHeaderIndex.get(CNAME_OIE)])) {
					//CNAME_OIE
					newPaymentAmount.put(APNAME_OIE, Decimal.valueof(values[columnHeaderIndex.get(CNAME_OIE)].trim()));
				}
				if(String.isNotBlank(values[columnHeaderIndex.get(CNAME_SUSPENSE)])) {
					//CNAME_SUSPENSE
					newPaymentAmount.put(APNAME_SUSPENSE, Decimal.valueof(values[columnHeaderIndex.get(CNAME_SUSPENSE)].trim()));
				}
				if(String.isNotBlank(values[columnHeaderIndex.get(CNAME_DAMAGED)])) {
					//CNAME_DAMAGED
					newPaymentAmount.put(APNAME_DAMAGE_WITH_PRODCODE, Decimal.valueof(values[columnHeaderIndex.get(CNAME_DAMAGED)].trim()));
				}



				//convert bu name and country to bu name
				String buNameConvert;
				String costCentreConvert;
				if(String.isNotBlank(values[columnHeaderIndex.get(CNAME_BU)]) && String.isNotBlank(values[columnHeaderIndex.get(CNAME_COUNTRY)])) {
					/* //CNAME_BU
                     if(values[columnHeaderIndex.get(CNAME_BU)].trim() == '334'){
                         buNameConvert = BUNAME_334;
                     }else if(values[columnHeaderIndex.get(CNAME_BU)].trim() == '326'){
                         buNameConvert = BUNAME_326;
                     }else if(values[columnHeaderIndex.get(CNAME_BU)].trim() == '329'){
                         buNameConvert = BUNAME_329;
                     }else if(values[columnHeaderIndex.get(CNAME_BU)].trim() == '335'){
                         buNameConvert = BUNAME_335;
                     }else if(values[columnHeaderIndex.get(CNAME_BU)].trim() == '393'){
                         buNameConvert = BUNAME_393;
                     }else if(values[columnHeaderIndex.get(CNAME_BU)].trim() == '394'){
                         buNameConvert = BUNAME_394;
                     }else if(values[columnHeaderIndex.get(CNAME_BU)].trim() == '28805'){
                         buNameConvert = BUNAME_28805;
                     }else if(values[columnHeaderIndex.get(CNAME_BU)].trim() == '32102'){
                         buNameConvert = BUNAME_32102;
                     }*/

					system.debug('desctiption to be match is :::'+ values[columnHeaderIndex.get(CNAME_BU)].trim() + values[columnHeaderIndex.get(CNAME_COUNTRY)]);
					Id buId = buDesM.get(values[columnHeaderIndex.get(CNAME_BU)].trim() + values[columnHeaderIndex.get(CNAME_COUNTRY)]);
					system.debug('buId::'+ buId );
					if(buId != null){
						buNameConvert = buNameM.get(buId);
						costCentreConvert = buNameCodeM.get(buId);
					}
					system.debug('final buNameConvert:::'+ buNameConvert);
					system.debug('final costCentreConvert:::'+ costCentreConvert);
				}

				//search for number of rows to be divided
				for (String apName : newPaymentAmount.keySet()){
					ASI_MFM_Payment_Line_Item__c payd=new ASI_MFM_Payment_Line_Item__c();
					payd.RecordTypeId = payDrecordtype;
					Id poL= poDM2.values()[0];
					system.debug('Get the First Line:'+ poDM2.values()[0]);

					system.debug('buNameConvert:'+ buNameConvert);
					system.debug('apName:'+ apName);
					system.debug('buM get : '+ buM.get(buNameConvert) + ', apM get : '+ apM.get(apName));
					system.debug('costCentreConvert :' + costCentreConvert);
					/*if(buM.get(buNameConvert) != null && apM.get(apName) != null){
						poL=poDM2.get(buNameConvert+'_'+apName);
					}*/ //Tony Yau Said : always assign the first line!
					//date sysDate = date.today();
					String parsedDate = values[columnHeaderIndex.get(CNAME_INV_DATE)].trim();

					system.debug('poL::'+ poL);
					payd.ASI_MFM_Payment__c=payheaderId;
					payd.ASI_MFM_Invoice_Date__c = Date.valueof(parsedDate);
					payd.ASI_MFM_Invoice_Number__c = values[columnHeaderIndex.get(CNAME_INVOICE_NO)].trim(); //CNAME_INVOICE_NO
					payd.ASI_MFM_PO_Line_Item__c= poL != null? pol:null;
					payd.ASI_MFM_Payment_Amount__c = newPaymentAmount.get(apName);

					Datetime dtStartDate = (Datetime) date.today();
					String dateString = dtStartDate.format('MM/yy');

					payd.ASI_MFM_Payment_List_Item_Description__c= String.isNotBlank(values[columnHeaderIndex.get(PAYMENT_LIST_ITEM_DESCRIPTION)]) ? values[columnHeaderIndex.get(PAYMENT_LIST_ITEM_DESCRIPTION)] : dateString+'-'+apName;
					payd.ASI_MFM_BU__c=buNameConvert != null ? buM.get(buNameConvert.trim()) != null? buM.get(buNameConvert.trim()): null: null;
					payd.ASI_MFM_AP_Code__c=apName != null ? apM.get(apName.trim()) != null? apM.get(apName.trim()): null: null;
					payd.ASI_MFM_A_c_Code__c=apName != null ? apacM.get(apName.trim()) != null? apacM.get(apName.trim()): null: null;
					payd.ASI_MFM_Cost_Centre_Code__c=costCentreConvert != null ? costCentreConvert:null;

					if(apName == APNAME_SUSPENSE){
						//CNAME_REMARK_FOR_SUSPENSE
						if(String.isBlank(values[columnHeaderIndex.get(CNAME_REMARK_FOR_SUSPENSE)].trim()) || String.isEmpty(values[columnHeaderIndex.get(CNAME_REMARK_FOR_SUSPENSE)].trim())){
							this.errorMessage += 'Error when parsing row:' + recordParseCount + ', Remark for Supense must present in same record<br/>';
							this.parseSuccess = false;
						}else{
							payd.ASI_MFM_Remark_for_Suspense__c = values[columnHeaderIndex.get(CNAME_REMARK_FOR_SUSPENSE)].trim();
						}
					}
					if(buNameConvert == null){
						this.errorMessage += 'Error when parsing row:' + recordParseCount + ', BU code cannot be matched<br/>';
						this.parseSuccess = false;
					}

					poAmount -= payd.ASI_MFM_Payment_Amount__c;

					System.debug('new item:: '+ payd);
					if(poL!=null && payd.ASI_MFM_BU__c!=null)
						newPayDL.add(payd);
				}


			}catch(Exception e){
				this.errorMessage += 'Error when parsing row:' + recordParseCount + ', ' + e.getMessage() + '<br/>';
				this.parseSuccess = false;
			}

			//System.debug('newPayDL::'+ newPayDL);


		}
		if(poAmount<0){
			this.errorMessage += 'Error. PO amount cannot greater than total amount of line item<br/>';
			this.parseSuccess = false;
		}
		//insert payment line item

		try {
			if(this.parseSuccess){
				Database.SaveResult[] stList = Database.insert(newPayDL,false);

				for (Database.SaveResult SR : stList) {
					if (!SR.isSuccess()) {
						this.errorMessage += 'Error when saving row : [' + recordCount + '] ' + SR.getErrors()[0].getMessage() + '<br/>';
						errRecordCount ++;
					}
					recordCount++;
				}
			}
			//insertert newPayDL;

		} catch (Exception e) {
			errRecordCount++;
			this.errorMessage += 'Error when saving : ' + e.getMessage();
			System.debug('Exception::'+ e);
			throw e;
		}

        
        
        ASI_MFM_Payment__c payment2 = [select id,ASI_MFM_Sys_Error_Log__c,ASI_MFM_Payment_Amt_Inv__c,ASI_MFM_Payment_Amount__c from ASI_MFM_Payment__c where id =:payheaderId  limit 1 ];
        if(this.errorMessage != ''){
            payment2.ASI_MFM_Sys_Error_Log__c = this.errorMessage;
        }
        payment2.ASI_MFM_Logistic__c = true;
        payment2.ASI_MFM_Payment_Amount__c = payment2.ASI_MFM_Payment_Amt_Inv__c;
        update payment2;
        
        
        
	}

	public void finish(Database.BatchableContext BC) {
		User u = [SELECT Id, Name, Email FROM User WHERE Id = :ownerId];

		List<Messaging.Email> emails = new List<Messaging.Email>();
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
//        System.debug('badLines in finish method : ' + badLines);
//
//        if (badLines.isEmpty()) {
//            mail.setSubject('Mass Upload Process is completed');
//
//            mail.setHtmlBody('Your mass upload submission was processed.<br/>' + '<br/><br/>Please do not reply to this message.<br/>Contact your system administrator if you feel you received this message in error.<br/>');
//            mail.setPlainTextBody('Your mass upload submission was processed.\n' + '\n\nPlease do not reply to this message.\nContact your system administrator if you feel you received this message in error.\n');
//        } else {
//            mail.setSubject('Mass Upload Process failed');
//
//            mail.setHtmlBody('Your mass upload submission failed.<br/>Please fix the following lines:<br/>' + String.join(badLines, '<br/>') + '<br/><br/>Please do not reply to this message.<br/>Contact your system administrator if you feel you received this message in error.<br/>');
//
//        }
		mail.setSubject('Mass Upload Process is completed');

		string mailMessgae = 'Your mass upload submission was processed. (Job Id:' + bc.getJobId() + ') <br/>';

		if(this.errorMessage != ''){
			mailMessgae += this.errRecordCount + + ' row of record(s) fail. No record created. <br/>';
			mailMessgae += 'Following are the error message: <br/>';
			mailMessgae += this.errorMessage;
		}else{
			mailMessgae += this.recordCount + ' row of record(s) have been created.<br/>';
		}

		mailMessgae += '<br/><br/>Please do not reply to this message.<br/>Contact your system administrator if you have received this message in error.<br/>';


		mail.setHtmlBody(mailMessgae);

		mail.setPlainTextBody(mailMessgae.replace('<br/>', '/n'));


		mail.setToAddresses(new List<String>{ u.email });
		emails.add(mail);
		Messaging.sendEmail(emails);

	}

}