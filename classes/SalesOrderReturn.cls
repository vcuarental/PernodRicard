/*******************************************************************************
*                           Company: ValueNet                                  *
*------------------------------------------------------------------------------*
*   Interfaz para la insercion/actualizacion de Oportunidades y sus Items      *
*******************************************************************************/
/********************************************************************************
* 
* MIGRACION LICENCIAS 
* AUTHOR: ZIMMIC                     DATE: 21/11/2016
*
********************************************************************************/

global class SalesOrderReturn {
    
    public static string transactionOrigin {get; set;}
    
    global class priceComponent{
        public Integer compCode;
        public String compName;
        public Decimal compPercentage;
        public Decimal compUnitPrice;
        public Decimal quantity;
        public Decimal compHeaderTotalPrice;

    }

    global class SalesOrderItem{
        webservice Integer NR_order_line_jde;//lineNumber
        webservice String Cd_product;//sku
        webservice Integer signedDatedReceipt;
        webservice Decimal QT_sales;//billedTotalQuantity
        webservice Decimal QT_Bonus;//bonusQuantity
        webservice Decimal PC_Bonus;
        webservice Decimal pc_discount;
        webservice Decimal Vl_Valor;//totalCost
        webservice Decimal percentualDiscount;
        webservice String cd_payment_term;//paymentTerm
        webservice String CD_unit;//salesUOM
        webservice String cd_unit_bonif;
        webservice String cd_line_status;//nextStatus
        webservice String orderLineStatusDescription;
        webservice String priceComponents;
        webservice String holdOrderCode;//backOrder
        webservice String cd_line_last_status;//lastStatus
        webservice String cancellationReason;
        webservice String estimatedDeliveryDate;
        webservice String logisticsPromisedDate;
        webservice String realDeliveryDate;
        webservice String promisedDate;
        webservice List<priceComponent> priceComponentsList;


        webservice String backOrder;
        webservice Decimal billedTotalQuantity;
        webservice Decimal bonusQuantity;
        webservice String lastStatus;
        webservice Integer lineNumber;
        webservice String nextStatus;
        webservice String paymentTerm;
        webservice String salesUOM;
        webservice String sku;
        webservice Decimal totalCost;
        webservice Decimal customerPrice;//Precio Cliente EDI

        
    }

    //Return codes
    public static integer success                 = 0;
    public static integer notFound_client         = 0; //Se cambia a 0 hasta que SOA no interprete el mensaje -1
    //public static integer notFound_client         = -1;
    public static integer notFound_opportunity    = -2;
    public static integer notFound_priceBook      = -3;
    public static integer notFound_priceBookEntry = -4;
    public static integer notFound_product        = -5;
    public static integer otherError              = -6;
    public static integer inactiveClientOwner     = -7;
    
    //Metodo privado que llama a las clases que contienen los procesos para cada pais
    webservice static Integer ETL_SalesOrderLoad(Integer Country, String cd_salesman, String NR_order_crm, Integer NR_order_JDE, Integer customer_AN8, Integer customer_AN8_entrega, String NR_customer_order, String companyCode, String DS_message1, String DS_message2, String DT_delivery, String Freight, String DT_Order, String DT_Faturamento, String CD_Order_Type, Integer cd_order_status, String CD_Deposito, String SalesOrder_Source, String priceComponents, integer returnCode, String returnMessage, String purchaseOrderUntil, String retentionReason, String paymentTerm, List<SalesOrderItem> listaItem){
        
        Integer codeRet; //
        String error;
        
        Savepoint sp = Database.setSavepoint();
        try{
            if(Country==1 || Country==5 || Country==6){
                //Brasil or Uruguay or Argentina
                codeRet = LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
            }else if(Country==12){
                //Mexico
                codeRet = LAT_MX_SalesOrderReturn.LAT_ETL_SalesOrderLoad(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
            }
        }catch(Exception e){
            Database.rollback(sp);
            error = e.getMessage();
            codeRet = otherError;
        }
        
        if(codeRet != 0){
            //DebugLog
            try{
                LAT_DebugUtil debug = new LAT_DebugUtil();
                debug.setOrigin('SalesOrderReturn-'+Country+'-'+SalesOrder_Source);
                debug.addTitle('Parameters');
                debug.addData('Country', String.ValueOf(Country));
                debug.addData('cd_salesman', String.ValueOf(cd_salesman));
                debug.addData('NR_order_crm', String.ValueOf(NR_order_crm));
                debug.addData('NR_order_JDE', String.ValueOf(NR_order_JDE));
                debug.addData('customer_AN8', String.ValueOf(customer_AN8));
                debug.addData('customer_AN8_entrega', String.ValueOf(customer_AN8_entrega));
                debug.addData('NR_customer_order', String.ValueOf(NR_customer_order));
                debug.addData('companyCode', String.ValueOf(companyCode));
                debug.addData('DS_message1', String.ValueOf(DS_message1));
                debug.addData('DS_message2', String.ValueOf(DS_message2));
                debug.addData('DT_delivery', String.ValueOf(DT_delivery));
                debug.addData('Freight', String.ValueOf(Freight));
                debug.addData('DT_Order', String.ValueOf(DT_Order));
                debug.addData('DT_Faturamento', String.ValueOf(DT_Faturamento));
                debug.addData('CD_Order_Type', String.ValueOf(CD_Order_Type));
                debug.addData('cd_order_status', String.ValueOf(cd_order_status));
                debug.addData('CD_Deposito', String.ValueOf(CD_Deposito));
                debug.addData('SalesOrder_Source', String.ValueOf(SalesOrder_Source));
                debug.addData('priceComponents', String.ValueOf(priceComponents));
                debug.addData('returnCode', String.ValueOf(returnCode));
                debug.addData('returnMessage', String.ValueOf(returnMessage));
                debug.addData('purchaseOrderUntil', String.ValueOf(purchaseOrderUntil));
                debug.addData('retentionReason', String.ValueOf(retentionReason));
                debug.addData('paymentTerm', String.ValueOf(paymentTerm));
                
                debug.addTitle('Items');
                for(SalesOrderReturn.SalesOrderItem item: listaItem){
                    debug.addData('Item - '+item.Cd_product, String.ValueOf(item));
                }
                
                debug.setResult(String.ValueOf(codeRet));
                
                if(error != null){
                    debug.addTitle('Error');
                    debug.addData('error', String.ValueOf(error));
                }
                debug.insertDebug();
            }catch(Exception e){}
        }
        return codeRet;
    }


    //MIGRATED 21/11/2016 
    webservice static Integer ETL_SalesOrderLoadMigrated(Integer Country, String cd_salesman, String NR_order_crm, Integer NR_order_JDE, Integer customer_AN8, Integer customer_AN8_entrega, String NR_customer_order, String companyCode, String DS_message1, String DS_message2, String DT_delivery, String Freight, String DT_Order, String DT_Faturamento, String CD_Order_Type, Integer cd_order_status, String CD_Deposito, String SalesOrder_Source, String priceComponents, integer returnCode, String returnMessage, String purchaseOrderUntil, String retentionReason, String paymentTerm, List<SalesOrderItem> listaItem){
        
        Integer codeRet; //
        String error;
        
        //Savepoint sp = Database.setSavepoint();
        try{
            if(Country==1 || Country==5 || Country==6){
                //Brasil or Uruguay or Argentina
                codeRet = LAT_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
            }else if(Country==12){
                //Mexico
                codeRet = LAT_MX_SalesOrderReturn.LAT_ETL_SalesOrderLoadMigrated(Country, cd_salesman, NR_order_crm, NR_order_JDE, customer_AN8, customer_AN8_entrega, NR_customer_order, companyCode, DS_message1, DS_message2, DT_delivery, Freight, DT_Order, DT_Faturamento, CD_Order_Type, cd_order_status, CD_Deposito, SalesOrder_Source, priceComponents, returnCode, returnMessage, purchaseOrderUntil, retentionReason, paymentTerm, listaItem);
            }
        }catch(Exception e){
            //Database.rollback(sp);
            System.debug('%%% Error en SalesOrderReturn : ' + e.getMessage() + ' Line: ' + e.getLineNumber() + ' Cause: ' + e.getCause());
            error = e.getMessage();
            codeRet = otherError;
            throw e;
        }
        
        if(codeRet != 0){
            //DebugLog
            try{
                LAT_DebugUtil debug = new LAT_DebugUtil();
                debug.setOrigin('SalesOrderReturn-'+Country+'-'+SalesOrder_Source);
                debug.addTitle('Parameters');
                debug.addData('Country', String.ValueOf(Country));
                debug.addData('cd_salesman', String.ValueOf(cd_salesman));
                debug.addData('NR_order_crm', String.ValueOf(NR_order_crm));
                debug.addData('NR_order_JDE', String.ValueOf(NR_order_JDE));
                debug.addData('customer_AN8', String.ValueOf(customer_AN8));
                debug.addData('customer_AN8_entrega', String.ValueOf(customer_AN8_entrega));
                debug.addData('NR_customer_order', String.ValueOf(NR_customer_order));
                debug.addData('companyCode', String.ValueOf(companyCode));
                debug.addData('DS_message1', String.ValueOf(DS_message1));
                debug.addData('DS_message2', String.ValueOf(DS_message2));
                debug.addData('DT_delivery', String.ValueOf(DT_delivery));
                debug.addData('Freight', String.ValueOf(Freight));
                debug.addData('DT_Order', String.ValueOf(DT_Order));
                debug.addData('DT_Faturamento', String.ValueOf(DT_Faturamento));
                debug.addData('CD_Order_Type', String.ValueOf(CD_Order_Type));
                debug.addData('cd_order_status', String.ValueOf(cd_order_status));
                debug.addData('CD_Deposito', String.ValueOf(CD_Deposito));
                debug.addData('SalesOrder_Source', String.ValueOf(SalesOrder_Source));
                debug.addData('priceComponents', String.ValueOf(priceComponents));
                debug.addData('returnCode', String.ValueOf(returnCode));
                debug.addData('returnMessage', String.ValueOf(returnMessage));
                debug.addData('purchaseOrderUntil', String.ValueOf(purchaseOrderUntil));
                debug.addData('retentionReason', String.ValueOf(retentionReason));
                debug.addData('paymentTerm', String.ValueOf(paymentTerm));
                                
                if(error != null){
                    debug.addTitle('Error');
                    debug.addData('error', String.ValueOf(error));
                }
                
                debug.addTitle('Items');
                for(SalesOrderReturn.SalesOrderItem item: listaItem){
                    debug.addData('Item - '+item.Cd_product, String.ValueOf(item));
                }
                
                debug.setResult(String.ValueOf(codeRet));

                debug.insertDebug();
            }catch(Exception e){
                 System.debug('%%% Error en SalesOrderReturn : ' + e.getMessage() + ' Line: ' + e.getLineNumber() + ' Cause: ' + e.getCause());
            }
        }
        return codeRet;
    }
    
    public static Datetime convertToDateTime(String dateStr){
        Datetime datetimeVal;
        try{datetimeVal = Datetime.ValueOf(dateStr);}catch(Exception e){}
        return datetimeVal;
    }
    
    public static Date convertToDate(String dateStr){
        Date dateVal;
        try{dateVal = Date.ValueOf(dateStr);}catch(Exception e){}
        return dateVal;
    }
    
    public static String getOrderType(Integer Country, String CD_Order_Type) {
        // Armo la descripcion que va en Type de la oportunidad a partir de la Custom Setting LAT_OrderTypes__c. 
        // Primero busco segun el pais (si hay algo customizado): <pais>-<orderType>
        // Si no encuentro, busco el estandar: <orderType>
        
        LAT_OrderTypes__c setting;
        String typeJDE = CD_Order_Type.toUpperCase();

        setting = LAT_OrderTypes__c.getInstance(String.valueOf(Country) + '-' + typeJDE);
        if (setting == null) {
            setting = LAT_OrderTypes__c.getInstance(typeJDE);
        }

        // formo el string de la forma '<orderType> - <description>'
        String typeSF = typeJDE;
        if (setting != null) {
            typeSF = typeSF + ' - ' + setting.LAT_Description__c;
        }
        return typeSF;
    }


    public static Double getOrderSigno(Integer Country, String CD_Order_Type) {
        
        LAT_OrderTypes__c setting;
        String typeJDE = CD_Order_Type.toUpperCase();

        setting = LAT_OrderTypes__c.getInstance(String.valueOf(Country) + '-' + typeJDE);
        if (setting == null) {
            setting = LAT_OrderTypes__c.getInstance(typeJDE);
        }

        if (setting != null) {
            if(setting.LAT_Signo__c != null){
                return setting.LAT_Signo__c;
            }
        }
        return 1;
    }
    
    public static void activatesPricebookEntrys(List<PricebookEntry> listPBEtoActivate){
        for(PricebookEntry pbe: listPBEtoActivate){
            pbe.isActive = true;
        }
        try{update listPBEtoActivate;}catch(DMLException e){}
    }
    
}