@isTest
private class LAT_PaymentCancelDA_Test {


	@isTest static void testcallout() {
		LAT_PaymentCancelDA.WSCancelarEncerrarDA_Execute_element cla =  new LAT_PaymentCancelDA.WSCancelarEncerrarDA_Execute_element();
    LAT_PaymentCancelDA.SdtMsg message = new LAT_PaymentCancelDA.SdtMsg();
    LAT_PaymentCancelDA.SdtMsg_SdtMsgItem messageItem = new LAT_PaymentCancelDA.SdtMsg_SdtMsgItem();
    LAT_PaymentCancelDA.WSCancelarEncerrarDA_ExecuteResponse_element ere = new LAT_PaymentCancelDA.WSCancelarEncerrarDA_ExecuteResponse_element();


		//clas.getValue();
		System.continuation con = new System.Continuation(10);
		LAT_PaymentCancelDA.WSCancelarEncerrarDASoapBindingQSPort po = new LAT_PaymentCancelDA.WSCancelarEncerrarDASoapBindingQSPort();
		LAT_PaymentCancelDA.WSCancelarEncerrarDA_Execute_element elem = new LAT_PaymentCancelDA.WSCancelarEncerrarDA_Execute_element();
		po.Execute(1,1,'test',1,'test','test');


	}

}