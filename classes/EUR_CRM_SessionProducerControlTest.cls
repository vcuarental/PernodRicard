/**
 * Created by illia on 31.07.18.
 */

@IsTest
private class EUR_CRM_SessionProducerControlTest {
    @IsTest
    private static void getSessionIdVfExceptionTest() {
        EUR_CRM_SessionProducerControl spc = new EUR_CRM_SessionProducerControl();
        String sid = EUR_CRM_SessionProducerControl.getSessionId() + '';
        System.assert(String.isNotEmpty(sid));

    }
}