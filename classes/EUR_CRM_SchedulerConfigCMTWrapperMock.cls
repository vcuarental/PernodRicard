@IsTest
public class EUR_CRM_SchedulerConfigCMTWrapperMock implements System.StubProvider {

    private Map<String, Integer> batchSizeByBatchClassName;

    public EUR_CRM_SchedulerConfigCMTWrapperMock(Map<String, Integer> batchSizeByBatchClassName) {
        this.batchSizeByBatchClassName = batchSizeByBatchClassName;
    }

    public Object handleMethodCall(
        Object stubbedObject
    ,   String stubbedMethodName
    ,   Type returnType
    ,   List<Type> listOfParamTypes
    ,   List<String> listOfParamNames
    ,   List<Object> listOfArgs) {

        if (stubbedMethodName.equalsIgnoreCase('getBatchSizeByBatchClassName')) {
            return this.batchSizeByBatchClassName;
        }

        return null;
    }

    public static Object createMock(Map<String, Integer> batchSizeByBatchClassName) {
        return Test.createStub(EUR_CRM_SchedulerConfigCMTWrapper.class, new EUR_CRM_SchedulerConfigCMTWrapperMock(batchSizeByBatchClassName));
    }

}