public without sharing class LAT_CTY_B2B_UtilsController {
    public class SiteStatus {
        @AuraEnabled
        public Boolean IsBlocked        { get; set; }
        @AuraEnabled
        public String BlockingMessage   { get; set; }

        public SiteStatus() {
            this.IsBlocked = false;
            this.BlockingMessage = '';
        }
    }

    @AuraEnabled
    public static SiteStatus retrieveSiteStatus() {
        List<LAT_CTY_B2B_Settings__c> lstSettings = null;
        Boolean boolIsBlocked = false;
        SiteStatus objSiteStatus = null;

        System.debug('retrieveSiteStatus [] ->');
        try {
            objSiteStatus = new SiteStatus();
            lstSettings = [SELECT Id, LAT_CTY_B2B_Message__c 
                            FROM LAT_CTY_B2B_Settings__c 
                            WHERE LAT_CTY_B2B_Is_Blocked__c = TRUE];
            
            boolIsBlocked = !lstSettings.isEmpty(); 

            if(boolIsBlocked) {
                objSiteStatus.IsBlocked = boolIsBlocked;
                objSiteStatus.BlockingMessage = lstSettings[0].LAT_CTY_B2B_Message__c;
            }
        } catch(Exception Ex) {
            LAT_Utils.handleException('retrieveSiteStatus', Ex.getMessage());
        }

        System.debug('retrieveSiteStatus [ ' + objSiteStatus + ' ] <-');
        return objSiteStatus;
    }
    
    public static Decimal getMinimunPrice(Id accountId) {
        Decimal mount = 0;
        List<Account> accList = [SELECT Sub_Channel_Rating__c
                                 FROM Account 
                                 WHERE Id = :accountId];
        if (accList.size() > 0) {
            Account acc = accList.get(0);
            List<LAT_Price_Channel_ARG__c> priceList = [SELECT Monto__c 
                                                        FROM LAT_Price_Channel_ARG__c 
                                                        WHERE LAT_SubChannel__c = :acc.Sub_Channel_Rating__c];
            if (priceList.size() > 0) {
                return priceList.get(0).Monto__c;
            } /* HABLANDO CON IGNACIO, CONVINO QUE LO QUE NECESITA ES QUE EL PRECIO MINIMO SE ASIGNE POR SUBCANAL UNICAMENTE.
             else {
                priceList = [Select Monto__c From LAT_Price_Channel_ARG__c Where Channel__c = :acc.Channel_Type__c and Sub_Channel__c = null];
                if (priceList.size() > 0) {
                    return priceList.get(0).Monto__c;
                }
            }*/
        }
        
        LAT_GeneralConfig__c objSetting = LAT_GeneralConfig__c.getInstance('LAT_CTY_B2B_AR_MinOrderPrice');
        
        System.debug('getMinimunPrice [] ->');
        
        if(objSetting == null) {
            objSetting = new LAT_GeneralConfig__c();
            objSetting.Name = 'LAT_CTY_B2B_AR_MinOrderPrice';
            objSetting.LAT_Value__c = '0';
            objSetting.LAT_Description__c = 'Importe mínimo para permitir cargar pedidos en B2B Argentina.';
            insert objSetting;
            
            return 0;
        }
        
        System.debug('getMinimunPrice [' + objSetting + '] <-');
        
        return Decimal.valueOf(objSetting.LAT_Value__c);
    }
}