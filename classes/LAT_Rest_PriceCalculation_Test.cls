@isTest
private class LAT_Rest_PriceCalculation_Test {
	
	@isTest static void test_method_one() {

		LAT_Rest_PriceCalculation.LineaPedido linea = new LAT_Rest_PriceCalculation.LineaPedido();
		linea.sku = '123';
		linea.unitOfMeasure = 'CA';
		linea.ratePercentCashDiscount = 2;
		linea.quantityOrdered = 1;
		Test.startTest();
		Map<String,String> mapa = new Map<String,String>();
        mapa.put('ANY key', 'ANY value');

        RestContext.response = new RestResponse();
        Test.setMock(HttpCalloutMock.class, new LAT_MockHttpResponseGenerator(1, 'Status', 'Test', mapa));
		List<LAT_Rest_PriceCalculation.LineaPedido> lineas = new List<LAT_Rest_PriceCalculation.LineaPedido>{linea};

		LAT_Rest_PriceCalculation.getPrice(lineas, '05', '', 'V00', Datetime.now(), 321145, 321145,  Datetime.now(),'1');
		Test.stopTest();
	}

	@isTest
  	static  void PriceCalcTypes(){
        
        LAT_JDE_PriceCalculation.priceCatalogueDetailsOutput out1 = new LAT_JDE_PriceCalculation.priceCatalogueDetailsOutput();
        LAT_JDE_PriceCalculation.discountAndChargeDetailsOutput out2 = new LAT_JDE_PriceCalculation.discountAndChargeDetailsOutput();
        LAT_JDE_PriceCalculation.discountAndChargeDetailsOutput out5 = new LAT_JDE_PriceCalculation.discountAndChargeDetailsOutput();
        LAT_JDE_PriceCalculation.messageValueObject out3 = new LAT_JDE_PriceCalculation.messageValueObject();
        LAT_JDE_PriceCalculation.e1MessageList out6 = new LAT_JDE_PriceCalculation.e1MessageList();
        LAT_JDE_PriceCalculation.priceCatalogueHeaderOutput out4 = new LAT_JDE_PriceCalculation.priceCatalogueHeaderOutput();
        LAT_JDE_PriceCalculation.BusinessServiceException_x out7 = new LAT_JDE_PriceCalculation.BusinessServiceException_x();
        LAT_JDE_PriceCalculation.valueObject out8 = new LAT_JDE_PriceCalculation.valueObject();
        LAT_JDE_PriceCalculation.errorRecords out9 = new LAT_JDE_PriceCalculation.errorRecords();
        LAT_JDE_PriceCalculation.e1Message out10 = new LAT_JDE_PriceCalculation.e1Message();
        LAT_JDE_PriceCalculation.responseValueObject out11 = new LAT_JDE_PriceCalculation.responseValueObject();


        //Generating Table
        out1.amountDiscountsAndCharges = 1;
        out1.amountExcise= 1;
        out1.amountExclusiveDiscountsAndCharges = 1;
        out1.amountGross= 1;
        out1.amountTax= 1;
        out1.amountTaxable= 1;
        out1.description1= '';
        out1.description2= '';
        out1.exciseRate = 1;
        out1.itemNumberShort = 1;
        out1.ordinalNumber = 1;
        out1.paymentTerms = 'TT';
        out1.quantityOrdered = 1;
        out1.ratePercentDiscountsAndCharges = 1;
        out1.secondItemNumber = 'Mx01';
        out1.taxRate = 1;
        out1.unitPrice = 1;
        out1.unitPriceExclusiveDiscountsAndCharges = 1;
        out1.unitPriceGross = 1;
        out1.unitofMeasure = 'CA';
        out1.discountAndChargeDetails = new List<LAT_JDE_PriceCalculation.discountAndChargeDetailsOutput>();
        out2.amountDiscountOrCharge= 1 ;
        out2.discountOrChargeGroup = 'IVA';
        out2.discountOrChargeType = 'IVA';
        out2.ratePercentDiscountsAndCharges=1;
        out2.unitDiscountOrCharge=1;
        out5.amountDiscountOrCharge = 1;
        out5.discountOrChargeGroup = 'IEPS';
        out5.discountOrChargeType = 'IEPS';
        out5.ratePercentDiscountsAndCharges=1;
        out5.unitDiscountOrCharge=1;
        out1.discountAndChargeDetails.add(out2);
        out1.discountAndChargeDetails.add(out5);
        out7.message = '';
        out7.requestID = '';
        out9.errorCode = '';
        out9.errorDescription = '';
        out10.message = '';
        out10.messagePrefix = '';
        out6.e1Messages = new List<LAT_JDE_PriceCalculation.e1Message>{out10};
        out11.errorRecords = new List<LAT_JDE_PriceCalculation.errorRecords>{out9};
        generatePriceTableForLineItem(out1);
    }
	
	    public static String generatePriceTableForLineItem(LAT_JDE_PriceCalculation.PriceCatalogueDetailsOutput lineItem){
        String beginTable = '<table cellspacing="2" width="100%"><font face="Lucida Console" size="10"><tr><td><b><center>' + System.Label.VF_VTS_00001_AR+ '</center></b></td><td><b><center>' + System.Label.VF_VTS_00002_AR+'</center></b></td> <td><b><center>' + System.Label.VF_VTS_00003_AR+ '</center></b></td></tr>';
		String beginTableWithDiscount = '<table cellspacing="2" width="100%"><font face="Lucida Console" size="10"><tr><td><b><center>' + System.Label.VF_VTS_00001_AR+ '</center></b></td><td><b><center>' + System.Label.VF_VTS_00004_AR+ '</center></b></td><td><b><center>' + System.Label.VF_VTS_00002_AR+'</center></b></td> <td><b><center>' + System.Label.VF_VTS_00003_AR+ '</center></b></td></tr>';
  		String beginTableHeader = '<table cellspacing="2" width="100%"><font face="Lucida Console" size="10"><tr><td><b><center>' + System.Label.VF_VTS_00001_AR+ '</center></b></td> <td><b><center>' + System.Label.VF_VTS_00003_AR+ '</center></b></td></tr>';
		String endTable = '</font></table>';
    	Map<string, string> mapFIeldsIds;
   
        system.debug('generatingTable+++' + lineItem);
        String table = '';
        String discountsTotal = '';
        // Informacion basica
        String rowCanal2Descuento = '';
        String descuentos = '';
        String impuestos = '';
        String rowSubtotal = '';
        String rowPrecioLista = '';
        String rowTotales = '';
        Decimal unitTotal = 0;
        Decimal total = 0;
        Decimal ivaPerUnit = (lineItem.amountTax / lineItem.quantityOrdered).setScale(2);
        Decimal IEPSPerUnit = (lineItem.amountExcise / lineItem.quantityOrdered).setScale(2);
        // Line 1 - Precio de Lista
        rowPrecioLista = '<tr><td width="250px">'+ Label.LAT_MX_VFP04_00032 + '</td> <td align="right" width="120px">' + LAT_Utils.formatNumber(lineItem.unitPriceExclusiveDiscountsAndCharges.setScale(2))+ '</td> <td align="right" width="120px">' +LAT_Utils.formatNumber(lineItem.amountExclusiveDiscountsAndCharges.setScale(2))+ '</td></tr>';
        unitTotal = lineItem.unitPriceExclusiveDiscountsAndCharges.setScale(2);
        total = lineItem.amountExclusiveDiscountsAndCharges.setScale(2);
        //Line 2 - Descuento Canal 2
        rowSubtotal =  '<tr><td width="250px">'+ Label.LAT_MX_VFP04_00033 + '</td> <td align="right" width="120px">' + LAT_Utils.formatNumber(lineItem.unitPrice.setScale(2) )+ '</td> <td align="right" width="120px">' +LAT_Utils.formatNumber(lineItem.amountTaxable.setScale(2))+ '</td></tr>';
        String rowIVA = '<tr><td width="250px">'+ 'IVA' + '</td> <td align="right" width="120px">' + LAT_Utils.formatNumber(ivaPerUnit) + '</td> <td align="right" width="120px">' +LAT_Utils.formatNumber( lineItem.amountTax.setScale(2))+ '</td></tr>';
            
        String rowIEPS = '<tr><td width="250px">'+ 'IEPS' + '</td> <td align="right" width="120px">' + LAT_Utils.formatNumber(IEPSPerUnit) + '</td> <td align="right" width="120px">' + LAT_Utils.formatNumber(lineItem.amountExcise.setScale(2)) + '</td></tr>';
        if (lineItem.discountAndChargeDetails != null) {    
            for (LAT_JDE_PriceCalculation.discountAndChargeDetailsOutput discount: lineItem.discountAndChargeDetails ) {
                if (discount.discountOrChargeType.trim().equals('D')){
                    descuentos += '<tr><td width="250px">'+ discount.discountOrChargeGroupDescription + '</td> <td align="right" width="120px">' + LAT_Utils.formatNumber( discount.unitDiscountOrCharge.setScale(2) )+ '</td> <td align="right" width="120px">' +LAT_Utils.formatNumber( discount.amountDiscountOrCharge.setScale(2) )+ '</td></tr>';
                    unitTotal += discount.unitDiscountOrCharge.setScale(2);
                    total += discount.amountDiscountOrCharge.setScale(2);
                } else if (discount.discountOrChargeType.trim().equals('C')) {
                        //impuestos += '<tr><td width="250px">'+ discount.discountOrChargeGroupDescription + '</td> <td align="right" width="120px">' + LAT_Utils.formatNumber( discount.unitDiscountOrCharge.setScale(2) )+ '</td> <td align="right" width="120px">' +LAT_Utils.formatNumber( discount.amountDiscountOrCharge.setScale(2) )+ '</td></tr>';
                        //unitTotal += discount.unitDiscountOrCharge.setScale(2);
                        //total += discount.amountDiscountOrCharge.setScale(2);
                } else if (discount.discountOrChargeType.trim().equals('O')) {
                        //otros += '<tr><td width="250px">'+ discount.discountOrChargeGroupDescription + '</td> <td align="right" width="120px">' + LAT_Utils.formatNumber( discount.unitDiscountOrCharge.setScale(2) )+ '</td> <td align="right" width="120px">' +LAT_Utils.formatNumber( discount.amountDiscountOrCharge.setScale(2) )+ '</td></tr>';
                }
            }
        }
        impuestos = rowIVA + rowIEPS;
        total += (lineItem.amountExcise + lineItem.amountTax).setScale(2);
        // FALTA EL ROW TOTALES
        rowTotales = '<tr><td width="250px">'+ Label.LAT_MX_VFP04_00034 + '</td> <td align="right" width="120px">' + LAT_Utils.formatNumber( (total/lineItem.quantityOrdered).setScale(2) )+ '</td> <td align="right" width="120px">' +LAT_Utils.formatNumber( total.setScale(2) )+ '</td></tr>';
         
        discountsTotal = rowPrecioLista + descuentos + rowSubtotal + impuestos + rowTotales;  

        // Hay que ver si no va con header
        table = beginTable + discountsTotal + endTable;
        System.debug('Salimos de generatePriceTableForLineItem MX con Tabla : '+ table);
        return table;
    }
}