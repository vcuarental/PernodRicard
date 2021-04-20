@RestResource(urlMapping='/LAT_Rest_SelloutCollect/*')
global without sharing class LAT_Rest_SelloutCollect {
	
	@HttpPatch
    global static void PUT() {
        RestRequest req = RestContext.request;
        SellOutCollect collects = (SellOutCollect)System.JSON.deserialize(req.requestBody.toString(), SellOutCollect.class);
        System.debug('collects : ' + collects);

        String res = doUpsert(collects);
        Boolean success = false;
        String idCollect = '';

        if (res == '') {
            success = true;
            idCollect = collects.sfdcId;
        }

        LAT_Rest_Contracts.ServiceResponse response = new LAT_Rest_Contracts.ServiceResponse(idCollect, res, success);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(response));

        System.debug('response : ' + response);
        if (response.success) {
            RestContext.response.statusCode     = 200;
        } else {
            RestContext.response.statusCode     = 400;
        }

    }
	
	@HttpPost
    global static void POST() {
        RestRequest req = RestContext.request;
        SellOutCollect collects = (SellOutCollect)System.JSON.deserialize(req.requestBody.toString(), SellOutCollect.class);
        System.debug('collects : ' + collects);

        String res = doUpsert(collects);
        Boolean success = false;
        String idCollect = '';

        if (res == '') {
            success = true;
            idCollect = collects.sfdcId;
        }

        LAT_Rest_Contracts.ServiceResponse response = new LAT_Rest_Contracts.ServiceResponse(idCollect, res, success);
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody   = Blob.valueOf(JSON.serialize(response));

        System.debug('response : ' + response);
        if (response.success) {
            RestContext.response.statusCode     = 200;
        } else {
            RestContext.response.statusCode     = 400;
        }

    }

    public static String doUpsert(SellOutCollect header) {
    	String retorno = '';
    	try{
	    	LAT_SellOutCollect__c nuevo = new LAT_SellOutCollect__c();
        	if(header.sfdcId != null)
	    	  if(header.sfdcId.startsWith('aKi')) nuevo.Id = header.sfdcId;
	    	if(header.account != '' && header.account != null) nuevo.AccountID__c = header.account;
	    	if(header.collectDate != '' && header.collectDate != null) nuevo.CollectDate__c = Date.valueOf(header.collectDate);
	    	if(header.creationDate != '' && header.creationDate != null) nuevo.CreationDate__c = Date.valueOf(header.creationDate);
	    	if(header.status != '' && header.status != null) nuevo.Status__c = header.status;
	    	if(header.referenceAccount != '' && header.referenceAccount != null) nuevo.ReferenceAccount__c = header.referenceAccount;
	    	if(header.referencedMonth != '' && header.referencedMonth != null) nuevo.ReferencedMonth__c = Date.valueOf(header.referencedMonth);
	    	if(header.unit != '' && header.unit != null) nuevo.Unit__c = header.unit;
	    	if(header.externalId != '' && header.externalId != null) nuevo.LAT_ExternalId__c = header.externalId;
	    	if(header.recordTypeId != '' && header.recordTypeId != null) nuevo.RecordTypeId = header.recordTypeId;

	    	upsert nuevo;
	    	header.sfdcId = nuevo.Id;
	    	List<LAT_SellOutCollectLine__c> toUpsert = new List<LAT_SellOutCollectLine__c>();
 	    	for(SellOutCollectLine line : header.SellOutCollectLine) {
	    		LAT_SellOutCollectLine__c nuevaLinea = new LAT_SellOutCollectLine__c();
                if(line.sfdcId != null)	{
                    if(line.sfdcId.startsWith('aKh')) {
                        nuevaLinea.Id = line.sfdcId;                    
                    } else {
                        nuevaLinea.SellOutCollect__c = nuevo.Id;
                    }
                } else {
                    nuevaLinea.SellOutCollect__c = nuevo.Id;
                }
		    	if(line.referenceProductGrouping != '' && line.referenceProductGrouping != null) nuevaLinea.ReferenceProductGrouping__c = line.referenceProductGrouping;
		    	if(line.sellOut != '' && line.sellOut != null) {
		    		nuevaLinea.SellOut__c = Decimal.valueOf(line.sellOut);
		    	} else {
		    		nuevaLinea.SellOut__c = 0;
		    	}
		    	
		    	if(line.stock != '' && line.stock != null) nuevaLinea.Stock__c = Decimal.valueOf(line.stock);
		    	if(line.positivated != null) nuevaLinea.Positivated__c = line.positivated;
		    	if(line.bottle != '' && line.bottle != null) nuevaLinea.Bottle__c = Decimal.valueOf(line.bottle);
		    	if(line.dose != '' && line.dose != null) nuevaLinea.Dose__c = Decimal.valueOf(line.dose);
		    	toUpsert.add(nuevaLinea);
	    	}
	    	if(toUpsert.size() > 0) {
	    		upsert toUpsert;
	    	}
    	} catch (DMLException e){
            //Added check for FIELD_CUSTOM_VALIDATION_EXCEPTION to return user friendly error.
            String errorMsg = e.getMessage();
            if(errorMsg.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                retorno = errorMsg.substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
            } else {
                retorno = errorMsg;
            }
        } catch (Exception e) {
			retorno = ''+ String.valueOf(e.getMessage());
		}

		return retorno;
    }

	public class SellOutCollect {

		public String sfdcid;
		public String account;
		public String collectDate;
		public String creationDate;
		public String status;
		public String referencedMonth;
		public String referenceAccount;
		public String recordTypeDevName;
		public String recordTypeId;
		public String unit;
		public String externalId;
		public List<SellOutCollectLine> sellOutCollectLine;

	}	
	public class SellOutCollectLine {
		public String sfdcid;
		public String referenceProductGrouping;
		public String sellOut;
		public String sellOutCollect;
		public String stock;
		public String name;
		public Boolean positivated;
		public String bottle;
		public String dose;
	}


}